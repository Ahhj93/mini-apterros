function state = apteros_physics_init()
% APTEROS_PHYSICS_INIT  Etat initial du modele physique simule (corps + 2
% plateaux). Angles en radians pour le corps, en degres pour les plateaux
% (comme motor_cc_model, coherent avec le reste du code).
state = struct( ...
    'z',0, 'vz',0, ...                              % altitude (m), vitesse (m/s)
    'roll',0, 'pitch',0, 'yaw',0, ...                % rad
    'p',0, 'q',0, 'r',0, ...                         % vitesses angulaires (rad/s)
    'theta1',0, 'omega1',0, ...                      % plateau 1 (deg, deg/s)
    'theta2',0, 'omega2',0, ...                      % plateau 2 (deg, deg/s)
    'az',0);                                         % acceleration verticale "libre" (m/s^2)
end
