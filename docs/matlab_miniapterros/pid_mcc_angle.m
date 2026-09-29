function [uk, st] = pid_mcc_angle(yc, yk, st, p)
% PID_MCC_ANGLE  Equivalent de Angle_plateau_1.vi et Angle_plateau_2.vi
% (asservissement d'angle du plateau, moteurs a courant continu 1 et 2).
%
%   yc : consigne    yk : angle mesure (hall)    st : etat    p : K, Ti, Td, Ts, N
%   Derivee calculee sur la mesure. Sortie saturee entre -1 et 1.
%   Le signe de uk donne le sens de rotation, |uk| l'amplitude (a confirmer
%   sur le diagramme : sortie "sens de rotation" / "PWM ESC").

if ~isfield(p,'N'), p.N = 0; end          % valeur du VI : filtre de derivee neutralise
Ts = p.Ts;

epsk = yc - yk;
pk   = p.K*epsk;
ik   = st.ik + p.K*(Ts/p.Ti)*epsk;
dyk  = p.N/(p.N+1)*st.dyk + 1/(p.N+1)*(yk - st.yk)/Ts;
dk   = -p.K*p.Td*dyk;
wk   = pk + ik + dk;
uk   = min(max(wk, -1), 1);

st.ik = ik;  st.dyk = dyk;  st.yk = yk;
end
