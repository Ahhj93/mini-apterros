function turbines_write(hw, io, duty)
% Envoie les rapports cycliques (50 Hz) sur les 3 canaux PWM des turbines.
hw.pwm_write(io.turb_thrust, duty.thrust,  50);
hw.pwm_write(io.turb_roll12, duty.roll_12, 50);
hw.pwm_write(io.turb_roll34, duty.roll_34, 50);
end
