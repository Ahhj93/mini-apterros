function outputs_zero(hw, io)
% OUTPUTS_ZERO  Equivalent de Remise_a_zero_moteurs.vi : met les 5 sorties PWM
% (3 turbines A/PWM0..2 + 2 moteurs B/PWM1, B/PWM2) a 0.05 de rapport cyclique
% a 50 Hz, exactement comme dans le VI.
chs = [{io.turb_thrust, io.turb_roll12, io.turb_roll34}, {io.mcc1.pwm, io.mcc2.pwm}];
for i = 1:numel(chs)
    hw.pwm_write(chs{i}, 0.05, 50);
end
end
