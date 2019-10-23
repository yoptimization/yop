%% Symbolics
yop.options.set_symbolics('symbolic math')
yop.options.set_symbolics('casadi')

%% Bryson-Denham
t = yop.parameter('t');
x = yop.variable('x', 2);
u = yop.variable('u');
x0 = yop.constant('x0', 2);

[f, y] = trolleyModel(t, x, u);

%% Goddard Rocket
t = yop.parameter('t');
x = yop.variable('x', 3);
u = yop.variable('u');

[f, y] = goddardModel(t,x,u);

%% 
c1 = 0 <= x(1) <= x(2) <= 10;
% Göra funktioner
% Kopiera grafer 



