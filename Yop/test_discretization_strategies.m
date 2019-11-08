%% Diskretisera genom att kontrollera value för x, u
yop.debug(true);
% yop.options.set_symbolics('symbolic math');
yop.options.set_symbolics('casadi');

t_0 = yop.parameter('t0');
t_f = yop.parameter('tf');
t = yop.variable('t');
x = yop.variable('x', [2,1]);
u = yop.variable('u');

[dx, y] = trolleyModel(t, x, u);
J_integrand = 1/2*u^2;

% Parametrisera signalerna
K = 10;
points = 'legendre';
d_x = 3;
d_u = 0;

%%
clear state control

h = (t_f.evaluate-t_0.evaluate)/K;

state(K+1) = yop.collocation_polynomial();
for k=1:K
    x_k = casadi.MX.sym(['x_' num2str(k)], size(x,1), (d_x+1));
    state(k).init(points, d_x, x_k, h*[(k-1) k]);
end
x_k = casadi.MX.sym(['x_' num2str(K+1)], size(x,1), 1);
state(K+1).init(points, 0, x_k, [t_f, t_f]);



control(K) = yop.collocation_polynomial();
for k=1:K
    name = ['u_' num2str(k)];
    u_k = casadi.MX.sym(name, size(u,1), (d_u+1));
    control(k).init(points, d_u, u_k, [(k-1)*h k*h]);
end

%%
ode_fun = casadi.Function('ode', {x.evaluate, u.evaluate}, {dx.evaluate});
tau = yop.collocation_polynomial.collocation_points(points, d_x);

c_ode = [];
for k=1:K
    for r=2:d_x
        x_kr = state(k).evaluate(tau(r));
        u_kr = control(k).evaluate(tau(r));
        c_ode = [c_ode; ode_fun(x_kr, u_kr) - state(k).differentiate.evaluate(tau(r))];
    end
end
















