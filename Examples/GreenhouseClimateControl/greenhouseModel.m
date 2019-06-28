function [dx, y] = greenhouseModel(t, x, u)
% Constants
p1 = 7.5e-8;
p2 = 1;
p3 = 0.1;
tf = 48;
% External inputs: [time, sunlight, outside temperature]
te  = (-1:0.2:49);
I = max(0, 800*sin(4*pi*te/tf-0.65*pi));
T0 = 15+10*sin(4*pi*te/tf-0.65*pi);

% Extract external inputs from table tue through interpolation
d1 = YopInterpolant(te, I);
d2 = YopInterpolant(te,T0);

dx1 = p1*d1(t)*x(2);
dx2 = p2*(d2(t)-x(2))+p3*u;
dx = [dx1; dx2];
y.te = te;
y.I = I;
y.T0 = T0;
end