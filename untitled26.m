%% 
% Hur hänger faser ihop?
%   - Tids- och tillståndstrajektorian är kontinuerliga
%     - Tiden måste hela tiden öka
%   - Det måste vara möjligt att speca { t_f(t)-t_0(t) '==' Delta_t }
%   - Göra alla klasser mottagliga för flera objekt
% 
% Bivillkor
%   - Symboliskt till höger och vänster -> separera i två bivillkor

% ocp.Options.setControlIntervals(100)
% ocp.Options.ControlIntervals = 100

% ocp = ocp1 + ocp2
% ocp.solve

% Parametrar

% 1. Skapa persistenta variabler för t0, tf
% 2. När användaren kör t_0, t_f kolla för tidsvariabeln och ersätt med de
% globala storheterna -> för detta krävs att alla operationer överlagras
% för YopTimepointExpression.
% Symboliska uttryck skapas av användarens bivillkor
% Bygg en casadi-Function som anropas med de rätta variablerna
% Korrekt uttryck uppnått!

% Wrap CasADi Variables?




ocp.max( rocket.height(t_f) );
ocp.min( a*rocket.weight(t_0) - b*rocket.height(t_f) );
ocp.st(...
    'systems', sys, ...
    t(t_0) == 0 , ...
    rocket.velocity(t_0) == 0, ...
    rocket.height(t_0) == 0, ...
    rocket.mass(t_0) == m0, ...
    0  <= rocket.height <= inf , ...
    mf <= rocket.mass  <= m0, ...
    0  <= rocket.fuelMassFlow <= Fm ...
    );











