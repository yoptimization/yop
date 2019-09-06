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


ocp.max(   rocket.height(t_f)  );
ocp.max( a*rocket.height(t_f) - b*rocket.weight(t_0) - c*integral(rocket.fuelFlow));
ocp.st(...
    'systems', sys, ...
    'dynamics', sys, ...
    t_0 == 0, ...
    rocket.velocity(t_0) == 0, ...
    rocket.height(t_0) == 0, ...
    rocket.mass(t_0) == m0, ...
    strict(0  <= rocket.height <= inf), ...
    mf <= rocket.mass  <= m0, ...
    0  <= rocket.fuelMassFlow <= Fm ...
    );

t_f - t_0 <= t_max;

rocket.velocity(t_0) + rocket.heigth(t_0) == 0; % -> utvärdera hela uttrycket

% hantering av:
t_f - t_0 == 10 % Två parametrar. 
% Eftersom de inte är av samma tidpunkt ska det specialhanteras.
% Persistenta variabler om de kallas utan argument. De används sedan för
% att göra anrop till 

ocp2 = copy(ocp1);
ocp2.remove( x(t_f) == 1 );
ocp2.add( x(t_f) == 0 );
ocp2.present;

ocp2phase = ocp1/10 + ocp2; % Dividera målfn för ocp1 med 10 och addera mål fn för 1 och 2
ocp2phase.solve('points', 'legendre', 'segments', [100; 100]);

% Två steg:
%   - Överlagra casadi
%   - Tolka relationer som bivillkor