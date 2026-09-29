function [imu, st] = xsens_read(s, st)
% XSENS_READ  Equivalent de Lecture_Xsens.vi + IMU_v2.vi (sans les canaux).
% Lit les octets disponibles, decode, garde la derniere mesure valide dans st.
%   imu.angles_rad : [roll pitch yaw] (rad)       (Euler recu en degres)
%   imu.gyro_rad_s : [x y z] (rad/s)
%   imu.freeacc    : [x y z] (m/s^2)   (freeaccZ = acceleration verticale)
n = s.NumBytesAvailable;
if n > 0
    st.buf = [st.buf, read(s, n, 'uint8')];
end
[o, st.buf] = xsens_parse(st.buf);
if ~isempty(o.euler_deg), st.last.angles_rad = o.euler_deg*pi/180; end
if ~isempty(o.gyro),      st.last.gyro_rad_s = o.gyro;             end
if ~isempty(o.freeacc),   st.last.freeacc    = o.freeacc;          end
imu = st.last;
end
