%% Symbolics
yop.options.set_symbolics('symbolic math')
yop.options.set_symbolics('casadi')

%% Bryson-Denham
t = yop.parameter('t');
x = yop.variable('x', 2);
u = yop.variable('u');

[f, y] = trolleyModel(t, x, u);

%% Goddard Rocket
t = yop.parameter('t');
x = yop.variable('x', 3);
u = yop.variable('u');

[f, y] = goddardModel(t,x,u);


