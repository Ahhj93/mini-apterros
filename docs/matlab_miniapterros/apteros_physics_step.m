function state = apteros_physics_step(state, duty, u_m1, u_m2, p)
% APTEROS_PHYSICS_STEP  Un pas du modele physique simule de l'Apteros.
% CE MODELE EST UNE APPROXIMATION construite pour tester la boucle de
% regulation de bout en bout (aucun VI ne donne la masse, les inerties ou les
% bras de levier reels) : ajuste les coefficients de p pour t'en rapprocher.
%
%   duty : sortie de turbines_mix (champs thrust, roll_12, roll_34)
%   u_m1, u_m2 : sorties de pid_mcc_angle pour les 2 moteurs de plateau
%   p : voir apteros_physics_params.m pour les coefficients et leur sens
Ts = p.Ts;

% --- Plateaux : reutilise le modele moteur (VI_Moteur_CC_v2) ---------------
[state.theta1, state.omega1] = motor_cc_model(u_m1, state.theta1, state.omega1, state.theta1*pi/180, p.motor);
[state.theta2, state.omega2] = motor_cc_model(u_m2, state.theta2, state.omega2, state.theta2*pi/180, p.motor);

% --- Translation verticale : poussee totale moins la pesanteur -------------
state.az = p.k_thrust*duty.thrust - p.g;
state.vz = state.vz + Ts*state.az;
state.z  = state.z  + Ts*state.vz;

% --- Roulis : poussee differentielle entre les 2 groupes de turbines -------
troll   = p.k_roll*(duty.roll_12 - duty.roll_34);
dp      = troll/p.I_roll - p.c_roll*state.p;
state.p = state.p + Ts*dp;
state.roll = state.roll + Ts*state.p;

% --- Tangage et lacet : deflexion du flux d'air par les plateaux -----------
% HYPOTHESE (comme dans main_control.m) : plateau 1 -> tangage, plateau 2 -> lacet.
tpitch  = p.k_plateau*(state.theta1*pi/180);
dq      = tpitch/p.I_pitch - p.c_pitch*state.q;
state.q = state.q + Ts*dq;
state.pitch = state.pitch + Ts*state.q;

tyaw    = p.k_plateau*(state.theta2*pi/180);
dr      = tyaw/p.I_yaw - p.c_yaw*state.r;
state.r = state.r + Ts*dr;
state.yaw = state.yaw + Ts*state.r;
end
