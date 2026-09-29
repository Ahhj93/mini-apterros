function hw = hw_sim()
% HW_SIM  Couche "materiel" simulee, pour faire tourner le code sans carte.
%
% Pour le vrai materiel, cree une fonction equivalente (hw_real.m) qui
% renvoie une structure avec les MEMES 4 fonctions :
%   hw.i2c_write(bus, addr, bytes)
%   bytes = hw.i2c_read(bus, addr, reg, n)   % ecrit 'reg' puis lit n octets
%   hw.dio_write(pin, val)                    % pin = 'B/DIO2', val = 0/1
%   hw.pwm_write(channel, duty, freq_hz)      % channel = 'A/PWM0', duty entre 0 et 1
% Le reste du code n'a alors pas besoin de changer.
% Les ecritures DIO/PWM sont memorisees dans la variable globale HWLOG.
global HWLOG
HWLOG = {};
hw.i2c_write = @sim_i2c_write;
hw.i2c_read  = @sim_i2c_read;
hw.dio_write = @sim_dio_write;
hw.pwm_write = @sim_pwm_write;
end

function sim_i2c_write(~, ~, ~)
end

function bytes = sim_i2c_read(~, addr, reg, n)
persistent k
if isempty(k), k = 0; end
bytes = zeros(1, n, 'uint8');
if reg == hex2dec('8F')                 % lidar : distance en cm sur 2 octets
    d = 150; bytes = uint8([floor(d/256), mod(d,256)]);
elseif reg == hex2dec('FE')             % capteur hall : angle 14 bits
    k = k + 40;                          % tourne doucement
    raw = mod(k, 16384);
    bytes = uint8([floor(raw/64), mod(raw,64)]);
end
end

function sim_dio_write(pin, val)
global HWLOG
HWLOG{end+1} = {'dio', pin, val};
end

function sim_pwm_write(ch, duty, freq)
global HWLOG
HWLOG{end+1} = {'pwm', ch, duty, freq};
end
