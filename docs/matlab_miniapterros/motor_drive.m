function motor_drive(hw, io, u, p)
% MOTOR_DRIVE  Equivalent de Vitesse_MCC_1.vi / Vitesse_MCC_2.vi : pilote un
% moteur a courant continu (pont en H : 2 sorties de sens + 1 PWM a 15 kHz).
%   MCC1 : sens B/DIO2 + B/DIO3, PWM B/PWM1        MCC2 : B/DIO0 + B/DIO1, PWM B/PWM2
%   u : commande normalisee -1..1 (sortie de pid_mcc_angle)
%   p.deadzone (0.025), p.offset (0), p.scale (0.6), p.freq (15000)
%
% Zone morte et decalage : repris de Test_vitesse_MCC1.vi
%   |u| < 0.025  ->  pwm = 0 ;  sinon  pwm = offset + |u|*(1-offset).
% p.scale = 0.6 et 15000 Hz sont les constantes de Vitesse_MCC_x.vi ; l'usage
% du 0.6 (facteur ? plafond ?) est suppose. Les 2 sorties de sens sont supposees
% complementaires (une a 1, l'autre a 0).
if ~isfield(p,'deadzone'), p.deadzone = 0.025; end
if ~isfield(p,'offset'),   p.offset   = 0;     end
if ~isfield(p,'scale'),    p.scale    = 0.6;   end
if ~isfield(p,'freq'),     p.freq     = 15000; end
if abs(u) < p.deadzone
    pwm = 0;
else
    pwm = p.offset + abs(u)*(1 - p.offset);
end
pwm = min(pwm, 1) * p.scale;
fwd = u > 0;
hw.dio_write(io.dir{1}, double(fwd));
hw.dio_write(io.dir{2}, double(~fwd));
hw.pwm_write(io.pwm, pwm, p.freq);
end
