function cfg = default_config()
% DEFAULT_CONFIG  Parametres de la boucle. LES GAINS SONT DES PLACEHOLDERS :
% les valeurs par defaut des faces avant LabVIEW n'ont pas ete recuperees.
% Recopie ici les gains reellement utilises (Kp, Ti, Td, Tr, Tad).
cfg.Ts = 0.01;                                   % periode (s) : 0.01 dans le VI principal
cfg.alt   = struct('Kp',1,'Ti',1,'Td',0.5,'Tr',0.5,'Tad',1,'Ts',cfg.Ts,'alpha',1,'N',10);
cfg.roll  = struct('Kp',1,'Ti',1,'Td',0.1,'Tr',0.1,'Ts',cfg.Ts,'N',10);
cfg.pitch = cfg.roll;
cfg.yaw   = cfg.roll;                            % PID_Yaw.vi = meme Formula Node que Roll/Pitch
cfg.mcc   = struct('K',1,'Ti',1,'Td',0.1,'Ts',cfg.Ts,'N',0);
cfg.hall  = struct('ratio',5,'offset_deg',0);
cfg.motor = struct('deadzone',0.025,'offset',0,'scale',0.6,'freq',15000);

% Adresses I2C
cfg.addr  = struct('lidar1',hex2dec('64'),'lidar2',hex2dec('62'), ...
                   'hall1',hex2dec('41'),'hall2',hex2dec('40'));

% Cablage myRIO (releve dans les VI)
cfg.io = struct( ...
    'turb_thrust','A/PWM0', 'turb_roll12','A/PWM2', 'turb_roll34','A/PWM1', ...
    'mcc1', struct('dir',{{'B/DIO2','B/DIO3'}}, 'pwm','B/PWM1'), ...
    'mcc2', struct('dir',{{'B/DIO0','B/DIO1'}}, 'pwm','B/PWM2'), ...
    'lidar_power','A/DIO13');

cfg.alpha_repos     = 0.5;    % puissance de repos des turbines de roulis (50 %)
cfg.plateau_max_deg = 70;     % limitation des plateaux (+-70 deg)
cfg.ramp_wait_s     = 0.025;  % pause de la rampe de demarrage (valeur supposee)
cfg.n_stabilisation = 50;     % nb de lectures avant d'enregistrer les valeurs au repos
cfg.change_lidar_address = false;   % true : lance Changement_adresse_Lidar (une seule fois !)

% Consignes (comme la face avant : angles en degres, altitude en m)
cfg.consigne = struct('alt',1.0,'roll_deg',0,'pitch_deg',0,'yaw_deg',0);

% Modele de simulation du plateau (VI_Moteur_CC_v2.vi)
cfg.simmot = struct('K1',660,'T',0.05,'Ts',cfg.Ts);   % T : valeur non recuperee
end
