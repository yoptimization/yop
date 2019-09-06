function [dx, y] = goddardModel(t, x, u)
% States and controls
v = x(1);
h = x(2);
m = x(3);
T = u;

% Parameters
c = 0.5;
g0 = 1;
h0 = 1;
D0 = 0.5*620;
b = 500;

% Drag
g = g0*(h0/h)^2;
D = D0*exp(-b*h);
F_D = D*v^2;

% Dynamics
dv = (T-sign(v)*F_D)/m-g;
dh = v;
dm = -T/c;
dx = [dv;dh;dm];

% Signals y
y.rocket.speed = v;
y.rocket.height = h;
y.rocket.fuelMass = m;
y.rocket.fuelMassFlow = dm;
y.rocket.thrust = T;
y.drag.coefficient = D;
y.drag.force = F_D;
y.gravity = g;
end