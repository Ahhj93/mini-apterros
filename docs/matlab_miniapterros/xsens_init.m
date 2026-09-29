function s = xsens_init(port, baud, freq_hz)
% XSENS_INIT  Equivalent de Initialisation_Xsens.vi (MTi sur port serie).
%   port : 'COM3', '/dev/ttyS0', ... (ASRL1::INSTR dans le VI)
%   baud : 230400 (valeur du VI)     freq_hz : frequence d'envoi (defaut VI : 10 Hz)
% Sequence : GoToConfig -> SetOutputConfiguration (Euler, gyro, acceleration
% libre) -> GoToMeasurement. Necessite serialport (MATLAB R2019b+).
% A TESTER sur le capteur : MID 0x30 / 0xC0 / 0x10 et IDs d'apres la doc XBus.
if nargin < 2, baud = 230400; end
if nargin < 3, freq_hz = 10;  end
s = serialport(port, baud);
s.Timeout = 1;
flush(s);
write(s, xbus_frame(hex2dec('30')), 'uint8');            % GoToConfig
pause(0.3); flush(s);
ids = [hex2dec('2030') hex2dec('8020') hex2dec('4030')];  % Euler, gyro, free acc
cfg = [];
for id = ids
    cfg = [cfg, floor(id/256), mod(id,256), floor(freq_hz/256), mod(freq_hz,256)]; %#ok<AGROW>
end
write(s, xbus_frame(hex2dec('C0'), cfg), 'uint8');       % SetOutputConfiguration
pause(0.3); flush(s);
write(s, xbus_frame(hex2dec('10')), 'uint8');            % GoToMeasurement
end
