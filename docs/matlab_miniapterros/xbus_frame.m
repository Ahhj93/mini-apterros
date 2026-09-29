function msg = xbus_frame(mid, data)
% XBUS_FRAME  Construit un message Xsens (protocole XBus) :
%   0xFA 0xFF MID LEN DATA... CHECKSUM   avec  somme(0xFF..CHECKSUM) = 0 mod 256
if nargin < 2, data = []; end
body = [255, mid, numel(data), data(:).'];
cs   = mod(-sum(body), 256);
msg  = uint8([250, body, cs]);
end
