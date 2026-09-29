function m = step_metrics(t, y, y0, yc, band)
% STEP_METRICS  Criteres classiques de reponse indicielle, calcules a la main
% (pas besoin de la Control System Toolbox).
%   t, y   : temps et signal simule
%   y0, yc : valeur de depart et consigne visee (l'echelon vaut yc - y0)
%   band   : demi-largeur de la bande de stabilisation, en fraction de
%            l'echelon (0.05 = crit ere a 5 %, valeur usuelle)
%
%   m.rise_time_s     : temps entre 10 % et 90 % de l'echelon
%   m.overshoot_pct   : depassement au-dela de la consigne, en % de l'echelon
%   m.settling_time_s : temps a partir duquel la reponse reste dans la bande
%   m.steady_state    : valeur moyenne des 10 derniers % de la simulation
%   m.steady_err      : consigne moins valeur en regime etabli
if nargin < 5, band = 0.05; end
t = t(:); y = y(:);
step_amp = yc - y0;
n = numel(y);

n_tail = max(1, round(0.1*n));
m.steady_state = mean(y(end-n_tail+1:end));
m.steady_err   = yc - m.steady_state;

if abs(step_amp) < 1e-9
    m.rise_time_s = NaN; m.overshoot_pct = NaN; m.settling_time_s = NaN;
    return
end

frac  = (y - y0)/step_amp;
i10   = find(frac >= 0.1, 1, 'first');
i90   = find(frac >= 0.9, 1, 'first');
if isempty(i10) || isempty(i90) || i90 <= i10
    m.rise_time_s = NaN;
else
    m.rise_time_s = t(i90) - t(i10);
end

dev = (y - yc) * sign(step_amp);                    % >0 = depassement au-dela de la consigne
m.overshoot_pct = max(0, max(dev)) / abs(step_amp) * 100;

tol     = band * abs(step_amp);
outside = abs(y - yc) > tol;
idx     = find(outside, 1, 'last');
if isempty(idx)
    m.settling_time_s = 0;
elseif idx == n
    m.settling_time_s = NaN;                         % jamais rentre dans la bande
else
    m.settling_time_s = t(idx + 1);
end
end
