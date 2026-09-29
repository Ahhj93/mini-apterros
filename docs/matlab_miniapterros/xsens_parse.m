function [out, rest] = xsens_parse(buf)
% XSENS_PARSE  Decode les paquets MTData2 (MID 0x36) presents dans buf (uint8).
% Renvoie le dernier jeu de mesures complet et les octets non consommes.
%   out.euler_deg : [roll pitch yaw] en degres      (ID 0x2030)
%   out.gyro      : vitesse angulaire (rad/s)       (ID 0x8020)
%   out.freeacc   : acceleration libre (m/s^2)      (ID 0x4030)
% Champs absents = [] . Flottants 32 ou 64 bits, big-endian.
% A VALIDER sur le capteur (IDs et format d'apres la doc XBus Xsens).
out = struct('euler_deg',[],'gyro',[],'freeacc',[]);
buf = uint8(buf(:).');
i = 1;
while i + 4 <= numel(buf)
    if buf(i) ~= 250 || buf(i+1) ~= 255      % preambule 0xFA 0xFF
        i = i + 1; continue
    end
    mid = buf(i+2);  len = double(buf(i+3));  hdr = 4;
    if len == 255                             % longueur etendue
        if i + 5 > numel(buf), break, end
        len = double(buf(i+4))*256 + double(buf(i+5));  hdr = 6;
    end
    last = i + hdr + len;                     % index de l'octet checksum
    if last > numel(buf), break, end          % paquet incomplet
    if mod(sum(double(buf(i+1:last))), 256) ~= 0
        i = i + 1; continue                   % checksum faux
    end
    if mid == 54                              % 0x36 = MTData2
        k = i + hdr;
        while k + 2 <= last - 1
            id = double(buf(k))*256 + double(buf(k+1));
            l  = double(buf(k+2));
            pl = buf(k+3:k+2+l);
            k  = k + 3 + l;
            base = bitand(id, 65520);         % 0xFFF0 : on ignore les bits de format
            if bitand(id,3) == 3, nb = 8; cls = 'double'; else, nb = 4; cls = 'single'; end
            if numel(pl) < 3*nb, continue, end
            v = zeros(1,3);
            for j = 1:3
                seg = pl((j-1)*nb+1 : j*nb);
                v(j) = double(typecast(seg(end:-1:1), cls));
            end
            switch base
                case 8240,  out.euler_deg = v;   % 0x2030
                case 32800, out.gyro      = v;   % 0x8020
                case 16432, out.freeacc   = v;   % 0x4030
            end
        end
    end
    i = last + 1;
end
rest = buf(i:end);
end
