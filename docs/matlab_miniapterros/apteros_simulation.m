function res = apteros_simulation(duration_s, consigne, do_plot)
% APTEROS_SIMULATION  Simulation complete, en boucle fermee, de l'Apteros :
% capteurs -> PID (altitude, roulis, tangage, lacet, angle des 2 plateaux)
% -> turbines + moteurs -> modele physique -> retour aux capteurs. Ne parle
% a aucun materiel : tout est calcule numeriquement (voir apteros_physics_*.m).
%
%   res = apteros_simulation()                          % 10 s, consignes par defaut
%   res = apteros_simulation(20)                         % 20 s
%   res = apteros_simulation(20, struct('alt',1.5,'roll_deg',5))
%   res = apteros_simulation(20, [], false)               % sans figure (calcul seul)
%
% res contient res.t et les colonnes de res.log : altitude, angles (roll,
% pitch, yaw, plateau1, plateau2) en degres, et les 5 commandes moteur.
%
% A REGLER AVANT DE FAIRE CONFIANCE AUX RESULTATS :
%   - les gains PID dans default_config.m (placeholders) ;
%   - les coefficients physiques dans apteros_physics_params.m (placeholders,
%     aucun VI ne donne la masse, les inerties ni les bras de levier reels) ;
%   - les hypotheses de cablage listees dans main_control.m (tangage/lacet
%     vers les plateaux 1 et 2, etc.).

if nargin < 1 || isempty(duration_s), duration_s = 10; end
if nargin < 3, do_plot = true; end

cfg = default_config();
if nargin >= 2 && ~isempty(consigne)
    fn = fieldnames(consigne);
    for i = 1:numel(fn), cfg.consigne.(fn{i}) = consigne.(fn{i}); end
end
phys = apteros_physics_params(cfg.Ts);
nsteps = round(duration_s/cfg.Ts);
d2r = pi/180;

% --- Etats (regulateurs + modele physique) ----------------------------------
stAlt = pid_altitude_state();
stRol = pid_attitude_state();  stPit = pid_attitude_state();  stYaw = pid_attitude_state();
stM1  = pid_mcc_angle_state(); stM2  = pid_mcc_angle_state();
S     = apteros_physics_init();

log = zeros(nsteps, 11);   % t alt roll pitch yaw plateau1 plateau2 u_alt u_rol u_pit u_yaw

for k = 1:nsteps
    t = (k-1)*cfg.Ts;

    % --- "Capteurs" = etat physique courant, sans bruit ---------------------
    alt  = S.z;
    ang  = [S.roll S.pitch S.yaw];
    gyr  = [S.p S.q S.r];
    gz   = S.az;
    a1   = S.theta1;   a2 = S.theta2;

    % --- Regulation (memes fonctions que main_control.m) ---------------------
    [u_alt, stAlt] = pid_altitude(cfg.consigne.alt, alt, gz, stAlt, cfg.alt);
    [u_rol, stRol] = pid_attitude(cfg.consigne.roll_deg*d2r,  ang(1), gyr(1), stRol, cfg.roll);
    [u_pit, stPit] = pid_attitude(cfg.consigne.pitch_deg*d2r, ang(2), gyr(2), stPit, cfg.pitch);
    [u_yaw, stYaw] = pid_attitude(cfg.consigne.yaw_deg*d2r,   ang(3), gyr(3), stYaw, cfg.yaw);

    duty = turbines_mix(max(u_alt,0), u_rol, cfg.alpha_repos);

    pmax = cfg.plateau_max_deg;
    c1 = min(max(u_pit*pmax, -pmax), pmax);
    c2 = min(max(u_yaw*pmax, -pmax), pmax);
    [u_m1, stM1] = pid_mcc_angle(c1, a1, stM1, cfg.mcc);
    [u_m2, stM2] = pid_mcc_angle(c2, a2, stM2, cfg.mcc);

    % --- Physique : avance d'un pas ------------------------------------------
    S = apteros_physics_step(S, duty, u_m1, u_m2, phys);

    log(k,:) = [t alt ang*180/pi a1 a2 u_alt u_rol u_pit u_yaw];
end

res.t   = log(:,1);
res.log = log;
res.cols = {'t','alt','roll_deg','pitch_deg','yaw_deg','plateau1_deg','plateau2_deg', ...
            'u_alt','u_roll','u_pitch','u_yaw'};

if do_plot
    figure('Name','Simulation Apteros');
    subplot(3,1,1);
    plot(res.t, log(:,2)); yline(cfg.consigne.alt,'--');
    ylabel('Altitude (m)'); grid on;
    subplot(3,1,2);
    plot(res.t, log(:,3:5)); legend('roll','pitch','yaw');
    ylabel('Angle corps (deg)'); grid on;
    subplot(3,1,3);
    plot(res.t, log(:,6:7)); legend('plateau 1','plateau 2');
    xlabel('t (s)'); ylabel('Angle plateau (deg)'); grid on;
end
end
