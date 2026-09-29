function [d_m, st] = lidar_read(hw, bus, addr, st, alpha)
% LIDAR_READ  Equivalent de Mesure_Lidar1.vi / Mesure_Lidar2.vi /
% Mesure_Lidar_Lateral.vi : lecture du registre 0x8F (2 octets = distance en
% cm), conversion en metres (/100), puis lissage passe-bas.
%
%   Lidar 1 : bus A, adresse 0x64      Lidar 2 : bus A, adresse 0x62
%   Lidar lateral : bus B (adresse a lire sur le diagramme)
%   alpha : coefficient de lissage. 0.1 = constante trouvee dans les VI ; sa
%           forme exacte (filtre 1er ordre ?) est a confirmer.
%   st    : struct('y', NaN) ; premiere mesure = valeur brute.
if nargin < 5, alpha = 0.1; end
b   = hw.i2c_read(bus, addr, hex2dec('8F'), 2);
d_m = (double(b(1))*256 + double(b(2)))/100;
if isnan(st.y), st.y = d_m; else, st.y = alpha*d_m + (1-alpha)*st.y; end
d_m = st.y;
end
