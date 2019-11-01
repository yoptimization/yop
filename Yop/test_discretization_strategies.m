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
nu = 1;
h = [t_0, t_f]; 
points = 'legendre';

state_deg = 2;
w_x = yop.variable('w_x', [(state_deg+1)*nx, 1]);
% w_x = 1:6;
state_coeffs = reshape(w_x, nx, state_deg+1);
state = yop.collocation_polynomial();
state.init(points, state_deg, state_coeffs, h);

control_deg = 0;
w_u = yop.variable('w_u', [(control_deg+1)*nu, 1]);
control_coeffs = w_u.reshape(nu, control_deg+1);
control = yop.collocation_polynomial();
control.init(points, control_deg, control_coeffs, h);

%% Styr parameterarna genom att sätta värden på t,x,z,u

% Diskretiera dynamiken på ett intervall
tau = yop.collocation_polynomial.collocation_points(points, state_deg);
for k=1 %2:d+1
    x_k = state.evaluate(tau(k));
    u_k = control.evaluate(tau(k));
    x.value = x_k;
    u.value = u_k;
    g_eq = state.differentiate.evaluate(tau(k)) - dx.evaluate;
end


















