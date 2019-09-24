%%
% Model
t = YopVar.variable('t');
x = YopVar.variable('x', 3);
u = YopVar.variable('u');

[dx, y] = goddardModel(t, x, u);
rocket = y.rocket;

% ocp
J = rocket.height(t_f);
% c0 = ddt(x) == dx
c1 = t_0 == 0;
c2 = rocket.height(t_0) == 1;
c3 = rocket.speed(t_0) == 0;
c4 = rocket.fuelMass(t_0) == 1;
c5 = 0 <= t_f <= inf;
c6 = 1 <= rocket.height <= inf;
c7 = -inf <= rocket.speed <= inf;
c8 = 0.6 <= rocket.fuelMass <= 1;
c9 = 0 <= rocket.thrust <= 3.5;


% -Discretization-
symbol = 'x';
dim = 1;
segments = 2;
deg = 3;
points = 'legendre';
x = YopSignal(symbol, dim, segments, deg, points, 0, 2);

% -Nlp vector-


% -Dynamics-


% -Constraints-




























