%% Diskretisera genom att kontrollera value för x, u
yop.debug(true);
yop.options.set_symbolics('symbolic math');
% yop.options.set_symbolics('casadi');
t_0 = yop.parameter('t0');
t_f = yop.parameter('tf');
t = yop.variable('t');
x = yop.variable('x', [2,1]);
u = yop.variable('u');

dx = trolleyModel(t, x, u);

% Parametrisera signalerna
nx = 2;
h = [t_0, t_f]; 
points = 'legendre';
deg = 2;
tau = yop.collocation_polynomial.collocation_points(points, deg);

w_x = yop.variable('w', [(deg+1)*nx, 1]);
coeffs = w_x.reshape(nx, deg+1);

cp = yop.collocation_polynomial();
cp.init(points, deg, coeffs, h);

cp1 = cp.evaluate(tau(1));

cp1.evaluate






















