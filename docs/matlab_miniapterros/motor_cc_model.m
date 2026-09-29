function [theta, omega] = motor_cc_model(u_prev, theta_prev, omega_prev, thetaP, p)
% MOTOR_CC_MODEL  Modele de simulation du moteur de plateau, equivalent du
% Formula Node de VI_Moteur_CC_v2.vi (angles en degres, vitesse en deg/s).
%   p.K1 : vitesse max (deg/s) pour u = 1 ; 340 (moteur 2023) ou 660 (colle avec
%          400 deg/s en boucle fermee, mesure de fevrier 2025 d'apres le VI)
%   p.T  : constante de temps (valeur non recuperee : a renseigner)   p.Ts : pas
%   thetaP : angle du plateau (rad) pour le couple resistant (comme dans le VI)
%
%   omega = (T/Ts)/(1+T/Ts)*omega_prev + K1/(1+T/Ts)*u_prev*(1 - 0.08*sin(thetaP)/sin(3.3*pi/180))
%   theta = theta_prev + Ts*omega
% Attention : le terme de couple resistant devient negatif au-dela d'environ 46
% degres ; le VI ne l'utilise donc valablement que pour de petits angles.
r     = p.T/p.Ts;
load_ = 1 - 0.08*sin(thetaP)/sin(3.3*pi/180);
omega = r/(1+r)*omega_prev + p.K1/(1+r)*u_prev*load_;
theta = theta_prev + p.Ts*omega;
end
