function duty = turbines_mix(poussee, roulis, alpha)
% TURBINES_MIX  Equivalent de Turbines.vi (Formula Node + limites 0.05..0.1).
% Les 3 sorties PWM des ESC tournent a 50 Hz ; le rapport cyclique va de
% 0.05 (1 ms = arret) a 0.10 (2 ms = pleine puissance).
%
%   poussee : 0..1 (commande d'altitude)     roulis : -1..1 (commande de roulis)
%   alpha   : "Puissance de repos roulis" en fraction (0.5 = 50 %)
%
% Formule du VI :  w1 = 0.05*(1+alpha) + 0.05*(1-alpha)*roulis
%                  w2 = 0.05*(1+alpha) - 0.05*(1-alpha)*roulis
% Association aux canaux (d'apres les libelles de chaque noeud PWM, a verifier
% sur le montage) :
%   A/PWM2 : "Controle roulis TR1 et TR2"  <- w1   (le lien w1/w2 est suppose)
%   A/PWM1 : "Controle roulis TR3 et TR4"  <- w2
%   A/PWM0 : "Controle Poussee"            <- 0.05*(1+poussee)   (formule supposee)
w1 = 0.05*(1+alpha) + 0.05*(1-alpha)*roulis;
w2 = 0.05*(1+alpha) - 0.05*(1-alpha)*roulis;
th = 0.05*(1 + poussee);
c  = @(x) min(max(x, 0.05), 0.1);                 % "lower limit" / "upper limit"
duty = struct('thrust', c(th), 'roll_12', c(w1), 'roll_34', c(w2));
end
