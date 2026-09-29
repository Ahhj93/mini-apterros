function lidar_change_address(hw, bus, cur_addr, new_addr, serial_hi, serial_lo, power_pin)
% LIDAR_CHANGE_ADDRESS  Equivalent de Changement_adresse_Lidar.vi (0x62 -> 0x64)
% et, avec les arguments inverses, de Reinitialisation_Lidar.vi (0x64 -> 0x62).
%
% Sequence lue dans les constantes des VI (LIDAR-Lite v3, a verifier avec la
% fiche technique Garmin), ecrite a l'adresse courante cur_addr :
%   0x18 <- serial_hi ; 0x19 <- serial_lo ; 0x1A <- new_addr ; 0x1E <- 0x08
% Valeurs des VI : serial_hi = 0x30, serial_lo = 0x52. Dans la procedure Garmin
% ce sont des octets propres a chaque capteur (numero de serie) : ne pas les
% reutiliser sur un autre lidar sans verifier.
% Le VI teste d'abord une lecture a l'adresse courante : si elle echoue, le
% changement est deja fait (ou le capteur absent). power_pin : sortie
% numerique (A/DIO13 dans le VI) pour couper/remettre l'alimentation.
try
    hw.i2c_read(bus, cur_addr, hex2dec('8F'), 1);
catch
    error('lidar_change_address:absent', ...
          'Aucun lidar ne repond a l''adresse 0x%02X (deja change ?).', cur_addr);
end
hw.i2c_write(bus, cur_addr, uint8([hex2dec('18') serial_hi]));
hw.i2c_write(bus, cur_addr, uint8([hex2dec('19') serial_lo]));
hw.i2c_write(bus, cur_addr, uint8([hex2dec('1A') new_addr]));
hw.i2c_write(bus, cur_addr, uint8([hex2dec('1E') hex2dec('08')]));
if nargin >= 7
    hw.dio_write(power_pin, 0); pause(0.5); hw.dio_write(power_pin, 1);
end
end
