function [uk, st] = pid_altitude(zc, zk, gk, st, p)
% PID_ALTITUDE  Equivalent de PID_Altitude.vi (Formula Node).
%
%   zc : consigne d'altitude (m)          zk : altitude mesuree (m)
%   gk : acceleration verticale (m/s^2)   st : etat memorise (Feedback Nodes)
%   p  : parametres  Kp, Ti, Td, Tr ("T retour"), Tad ("T Anti derive"), Ts,
%                    alpha (defaut 1), N (defaut 10)
%
%   Sortie uk saturee entre 0 et 1 (les turbines ne poussent que vers le haut).
%   Anti-windup par "back-calculation" : terme Kp*Ts/Tad*(uk_1 - wk_1).
%
%   NB : avec alpha = 1 (valeur du VI), la vitesse vk n'est que l'integrale de
%   l'acceleration, sans recalage par le lidar. Le commentaire du VI suggere
%   alpha = 0.95 quand l'accelerometre est utilise -> a verifier.

if ~isfield(p,'alpha'), p.alpha = 1;  end
if ~isfield(p,'N'),     p.N     = 10; end
Ts = p.Ts;

vk   = p.alpha*(st.vk + Ts*gk) + (1-p.alpha)*(p.N/(p.N+1)*st.vk + 1/(p.N+1)*(zk - st.zk)/Ts);
epsk = (zc - zk) - vk*p.Tr;
ik   = st.ik + p.Kp*Ts/p.Ti*epsk + p.Kp*Ts/p.Tad*(st.uk - st.wk);
pk   = p.Kp*epsk;
dk   = -p.Kp*p.Td*(vk + p.Tr*gk);
wk   = dk + ik + pk;
uk   = min(max(wk, 0), 1);

st.vk = vk;  st.zk = zk;  st.ik = ik;  st.uk = uk;  st.wk = wk;
end
