function T = apteros_performance_report(duration_s, do_plot)
% APTEROS_PERFORMANCE_REPORT  Lance un echelon sur chaque boucle (altitude,
% roulis, tangage, lacet) et chiffre la reponse : temps de montee,
% depassement, temps de stabilisation, erreur statique. Sert de preuve
% chiffree de la qualite de l'asservissement (a montrer telle quelle).
%
%   T = apteros_performance_report();          % 15 s par boucle, avec figures
%   T = apteros_performance_report(15, false);  % sans figures
if nargin < 1 || isempty(duration_s), duration_s = 15; end
if nargin < 2, do_plot = true; end

scenarios = { ...
    'Altitude',      struct('alt',1.0),                          2, 'alt (m)'; ...
    'Roulis',        struct('roll_deg',10),                      3, 'roll (deg)'; ...
    'Tangage',       struct('pitch_deg',10),                     4, 'pitch (deg)'; ...
    'Lacet',         struct('yaw_deg',10),                       5, 'yaw (deg)' };

names = {}; rise=[]; over=[]; settle=[]; sse=[];
if do_plot, figure('Name','Reponses indicielles Apteros'); end

for i = 1:size(scenarios,1)
    [label, consigne, col, ylab] = scenarios{i,:};
    res = apteros_simulation(duration_s, consigne, false);
    y0  = res.log(1, col);
    fn  = fieldnames(consigne);
    yc  = consigne.(fn{1});

    m = step_metrics(res.t, res.log(:,col), y0, yc);
    names{end+1}  = label; %#ok<AGROW>
    rise(end+1)   = m.rise_time_s;
    over(end+1)   = m.overshoot_pct;
    settle(end+1) = m.settling_time_s;
    sse(end+1)    = m.steady_err;

    if do_plot
        subplot(2,2,i);
        plot(res.t, res.log(:,col), 'b', 'LineWidth', 1.2); hold on;
        yline(yc, 'r--');
        title(sprintf('%s : montee %.2fs, depas. %.1f%%, stabil. %.2fs, err. %.3g', ...
              label, m.rise_time_s, m.overshoot_pct, m.settling_time_s, m.steady_err));
        xlabel('t (s)'); ylabel(ylab); grid on;
    end
end

if exist('table', 'builtin') || exist('table', 'file')
    T = table(names', rise', over', settle', sse', ...
        'VariableNames', {'Boucle','Temps_montee_s','Depassement_pct','Temps_stabilisation_s','Erreur_statique'});
    disp(T);
else
    % Octave (ou MATLAB ancien) sans la fonction table : affichage manuel.
    T = struct('Boucle',{names},'Temps_montee_s',rise,'Depassement_pct',over, ...
               'Temps_stabilisation_s',settle,'Erreur_statique',sse);
    fprintf('%-10s %14s %16s %20s %16s\n', 'Boucle','montee(s)','depas.(%)','stabilisation(s)','err. statique');
    for i = 1:numel(names)
        fprintf('%-10s %14.3f %16.2f %20.3f %16.4g\n', names{i}, rise(i), over(i), settle(i), sse(i));
    end
end
end
