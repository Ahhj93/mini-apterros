function lidar_reinit_address(hw, bus, cur_addr, serial_hi, serial_lo)
% Equivalent de Reinitialisation_Lidar.vi : remet un lidar a l'adresse 0x62.
if nargin < 3, cur_addr = hex2dec('64'); end
if nargin < 4, serial_hi = hex2dec('30'); serial_lo = hex2dec('52'); end
lidar_change_address(hw, bus, cur_addr, hex2dec('62'), serial_hi, serial_lo);
end
