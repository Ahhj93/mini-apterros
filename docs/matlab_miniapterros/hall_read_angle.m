function [angle_deg, st] = hall_read_angle(hw, bus, addr, st, p)
% HALL_READ_ANGLE  Equivalent de Lecture_angle_MCC1.vi / MCC2.vi.
%
% Capteur magnetique 14 bits sur I2C (bus B). On lit 2 octets a partir du
% registre 0xFE : 8 bits de poids fort, puis 6 bits de poids faible (les bits
% 7 et 6 de l'octet 0xFF sont ignores) -> compatible avec un AS5048B.
%   MCC1 : adresse 0x41      MCC2 : adresse 0x40   (d'apres les constantes)
% angle capteur = raw/16384*360 ; depliage multi-tours (Unwrap Phase) ;
% angle en sortie de reducteur = angle capteur / p.ratio (ratio 5 dans le VI).
%
%   p.ratio     : rapport de reduction (defaut 5)
%   p.offset_deg: decalage a retirer (defaut 0). Une constante 57.8 existe dans
%                 les VI, son role n'est pas confirme (zero mecanique ?).
if ~isfield(p,'ratio'),      p.ratio = 5;       end
if ~isfield(p,'offset_deg'), p.offset_deg = 0;  end
b   = hw.i2c_read(bus, addr, hex2dec('FE'), 2);
raw = double(b(1))*64 + double(bitand(b(2), uint8(63)));
a   = raw/16384*360;
if isnan(st.prev)
    st.cum = a;
else
    d = mod(a - st.prev + 180, 360) - 180;   % ecart ramene dans [-180, 180[
    st.cum = st.cum + d;
end
st.prev   = a;
angle_deg = st.cum/p.ratio - p.offset_deg;
end
