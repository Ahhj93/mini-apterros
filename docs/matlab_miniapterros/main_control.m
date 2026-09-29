function log = main_control(hw, cfg, nsteps)
% MAIN_CONTROL  Equivalent de Table_controle.vi (mode "vol autonome").
% Sequence relevee dans le VI :
%   1. Initialisation : Xsens (230400 bauds), adresses lidar, lidars, remise a zero
%   2. Lecture de tous les capteurs pour les stabiliser, puis enregistrement des
%      valeurs au repos (variables globales de Globalvi.vi)
%   3. Rampe des turbines de roulis de 0 a 50 % de puissance
%   4. Boucle a 10 ms : capteurs -> PID (roulis, tangage, lacet, altitude) ->
%      turbines + plateaux (angle des moteurs CC limite a +-70 deg)
%   5. Arret : remise a zero des sorties, fermeture
% Le cablage exact (quel PID alimente quelle sortie) n'a pas pu etre lu ; les
% choix marques HYPOTHESE sont deduits des libelles et sont a verifier.
%
%   log = main_control(hw_sim(), default_config(), 200);
if nargin < 1, hw  = hw_sim();         end
if nargin < 2, cfg = default_config(); end
if nargin < 3, nsteps = 100;           end
io = cfg.io;

% --- Etats -----------------------------------------------------------------
stAlt = pid_altitude_state();
stRol = pid_attitude_state();  stPit = pid_attitude_state();  stYaw = pid_attitude_state();
stM1  = pid_mcc_angle_state(); stM2  = pid_mcc_angle_state();
stH1  = hall_state();  stH2 = hall_state();
stL1  = lidar_state(); stL2 = lidar_state();
stX   = xsens_state();     % avec le vrai capteur : s = xsens_init('COM3',230400,100);

% --- 1. Initialisation -----------------------------------------------------
outputs_zero(hw, io);
if cfg.change_lidar_address
    lidar_change_address(hw, 'A', hex2dec('62'), cfg.addr.lidar1, hex2dec('30'), hex2dec('52'), io.lidar_power);
end
lidar_init(hw, 'A', cfg.addr.lidar1);
lidar_init(hw, 'A', cfg.addr.lidar2);

% --- 2. Stabilisation puis valeurs au repos ------------------------------
acc = zeros(1,1+3+3);
for k = 1:cfg.n_stabilisation
    imu = stX.last;     % avec le vrai capteur : [imu, stX] = xsens_read(s, stX);
    [z1, stL1] = lidar_read(hw, 'A', cfg.addr.lidar1, stL1);
    [z2, stL2] = lidar_read(hw, 'A', cfg.addr.lidar2, stL2);
    [~, stH1]  = hall_read_angle(hw, 'B', cfg.addr.hall1, stH1, cfg.hall);
    [~, stH2]  = hall_read_angle(hw, 'B', cfg.addr.hall2, stH2, cfg.hall);
    acc = [(z1+z2)/2, imu.angles_rad, imu.gyro_rad_s];
end
zero = acc;     % Altitude initiale, Angle Initial R/P/Y, Vitesse Initiale R/P/Y

% --- 3. Rampe des turbines de roulis (0 -> 50 %) ----------------------------
for i = 0:round(100*cfg.alpha_repos)
    w = 0.05 + 0.05*i/100;                  % formule du VI (alpha = 1 suppose)
    hw.pwm_write(io.turb_roll12, w, 50);
    hw.pwm_write(io.turb_roll34, w, 50);
    pause(cfg.ramp_wait_s);
end

% --- 4. Boucle de regulation -------------------------------------------------
log = zeros(nsteps, 8);      % [t alt u_alt u_roll u_pitch u_yaw plateau1 plateau2]
for k = 1:nsteps
    t = (k-1)*cfg.Ts;
    imu = stX.last;         % avec le vrai capteur : [imu, stX] = xsens_read(s, stX);
    [z1, stL1] = lidar_read(hw, 'A', cfg.addr.lidar1, stL1);
    [z2, stL2] = lidar_read(hw, 'A', cfg.addr.lidar2, stL2);
    [a1, stH1] = hall_read_angle(hw, 'B', cfg.addr.hall1, stH1, cfg.hall);
    [a2, stH2] = hall_read_angle(hw, 'B', cfg.addr.hall2, stH2, cfg.hall);

    alt = (z1+z2)/2 - zero(1);                  % HYPOTHESE : moyenne des 2 lidars, relative au repos
    ang = imu.angles_rad - zero(2:4);           % HYPOTHESE : angles relatifs au repos
    gyr = imu.gyro_rad_s - zero(5:7);
    gz  = imu.freeacc(3);

    d2r = pi/180;
    [u_alt, stAlt] = pid_altitude(cfg.consigne.alt, alt, gz, stAlt, cfg.alt);
    [u_rol, stRol] = pid_attitude(cfg.consigne.roll_deg*d2r,  ang(1), gyr(1), stRol, cfg.roll);
    [u_pit, stPit] = pid_attitude(cfg.consigne.pitch_deg*d2r, ang(2), gyr(2), stPit, cfg.pitch);
    [u_yaw, stYaw] = pid_attitude(cfg.consigne.yaw_deg*d2r,   ang(3), gyr(3), stYaw, cfg.yaw);

    % Turbines : altitude -> poussee, roulis -> difference entre les 2 groupes
    turbines_write(hw, io, turbines_mix(max(u_alt,0), u_rol, cfg.alpha_repos));

    % Plateaux : HYPOTHESE tangage -> plateau 1, lacet -> plateau 2, echelle +-70 deg
    pmax = cfg.plateau_max_deg;
    c1 = min(max(u_pit*pmax, -pmax), pmax);
    c2 = min(max(u_yaw*pmax, -pmax), pmax);
    [u_m1, stM1] = pid_mcc_angle(c1, a1, stM1, cfg.mcc);
    [u_m2, stM2] = pid_mcc_angle(c2, a2, stM2, cfg.mcc);
    motor_drive(hw, io.mcc1, u_m1, cfg.motor);
    motor_drive(hw, io.mcc2, u_m2, cfg.motor);

    log(k,:) = [t alt u_alt u_rol u_pit u_yaw c1 c2];
    pause(cfg.Ts);          % en temps reel strict, utiliser un timer
end

% --- 5. Arret ----------------------------------------------------------------
outputs_zero(hw, io);
end
