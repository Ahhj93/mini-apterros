function p = apteros_physics_params(Ts)
% APTEROS_PHYSICS_PARAMS  Coefficients du modele physique simule.
% TOUS SONT DES PLACEHOLDERS (rien dans les VI ne donne la masse, les
% inerties ni les bras de levier reels) : a remplacer par tes propres valeurs
% si tu les connais (pesee, calcul d'inertie, essais...).
if nargin < 1, Ts = 0.01; end
p.Ts       = Ts;
p.g        = 9.81;
p.k_thrust = p.g/0.075;  % duty.thrust vaut entre 0.05 et 0.10 (turbines_mix) ; le vol
                          % stationnaire est cale au milieu (duty = 0.075, poussee = 0.5)
p.I_roll   = 0.02;       % kg.m^2 (inertie de roulis)
p.k_roll   = 4;          % couple (N.m) pour un ecart de duty de 1 entre les 2 groupes
p.c_roll   = 0.5;        % amortissement (1/s)
p.I_pitch  = 0.02;       p.k_plateau = 0.3;  p.c_pitch = 0.5;
p.I_yaw    = 0.02;       p.c_yaw     = 0.5;   % k_plateau partage avec le tangage
p.motor    = struct('K1',660,'T',0.05,'Ts',Ts);   % modele du moteur de plateau (VI_Moteur_CC_v2)
end
