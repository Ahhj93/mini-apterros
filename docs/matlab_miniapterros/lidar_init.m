function lidar_init(hw, bus, addr)
% LIDAR_INIT  Equivalent de Initialisation_Lidar.vi : ecritures I2C de
% configuration (mode continu). Les paires [registre valeur] sont celles des
% constantes du VI ; elles correspondent a un Garmin LIDAR-Lite v3.
% L'ORDRE d'execution exact est a verifier sur le diagramme.
%   bus  : 'A' ou 'B' (connecteur I2C)      addr : adresse 7 bits (ex. 0x62)
cfg = [ hex2dec('02') hex2dec('80');    % 0x02 <- 0x80
        hex2dec('04') hex2dec('28');    % 0x04 <- 0x28
        hex2dec('11') hex2dec('FF');    % 0x11 <- 0xFF (mesures en boucle infinie)
        hex2dec('45') hex2dec('05');    % 0x45 <- 0x05
        hex2dec('00') hex2dec('04') ];  % 0x00 <- 0x04 (lance les mesures)
for i = 1:size(cfg,1)
    hw.i2c_write(bus, addr, uint8(cfg(i,:)));
    pause(0.01);
end
end
