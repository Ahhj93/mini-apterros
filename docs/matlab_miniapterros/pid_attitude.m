function [uk, st] = pid_attitude(yc, yk, Omega_k, st, p)
% PID_ATTITUDE  Equivalent de PID_Pitch.vi, PID_Roll.vi et PID_Yaw.vi
% (les trois ont le meme Formula Node).
%
%   yc : consigne d'angle        yk : angle mesure
%   Omega_k : vitesse angulaire mesuree (gyro)
%   p  : Kp, Ti, Td, Tr ("T retour"), Ts, N (defaut 10)
%
%   Sortie uk saturee entre -1 et 1. Pas d'anti-windup dans ces VI.

if ~isfield(p,'N'), p.N = 10; end
Ts = p.Ts;

epsk    = (yc - yk) - Omega_k*p.Tr;
ik      = st.ik + p.Kp*Ts/p.Ti*epsk;
pk      = p.Kp*epsk;
dOmega  = p.N/(p.N+1)*st.dOmega + 1/(p.N+1)*(Omega_k - st.Omega)/Ts;
dk      = -p.Kp*p.Td*(Omega_k + p.Tr*dOmega);
wk      = dk + ik + pk;
uk      = min(max(wk, -1), 1);

st.ik = ik;  st.dOmega = dOmega;  st.Omega = Omega_k;
end
