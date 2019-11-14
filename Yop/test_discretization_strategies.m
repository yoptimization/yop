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

w_x = [];
state(K+1) = yop.collocation_polynomial();
for k=1:K
    x_k = casadi.MX.sym(['x_' num2str(k)], size(x,1), (d_x+1));
    state(k).init(points, d_x, x_k, h*[(k-1) k]);
    w_x = [w_x; x_k(:)];
end
x_k = casadi.MX.sym(['x_' num2str(K+1)], size(x,1), 1);
state(K+1).init(points, 0, x_k, [t_f, t_f]);
w_x = [w_x; x_k(:)];


w_u = [];
control(K) = yop.collocation_polynomial();
for k=1:K
    name = ['u_' num2str(k)];
    u_k = casadi.MX.sym(name, size(u,1), (d_u+1));
    control(k).init(points, d_u, u_k, [(k-1)*h k*h]);
    w_u = [w_u; u_k(:)];
end

%%
ode_fun = casadi.Function('ode', {x.evaluate, u.evaluate}, {dx.evaluate});
tau = yop.collocation_polynomial.collocation_points(points, d_x);
tau_u = yop.collocation_polynomial.collocation_points(points, d_u);

c_ode = [];
for k=1:K
    for r=2:d_x+1
        x_kr = state(k).evaluate(tau(r));
        u_kr = control(k).evaluate(tau(r));
        c_ode = [c_ode; ode_fun(x_kr, u_kr) - state(k).differentiate.evaluate(tau(r))];
    end
end

c_continuity = [];
for k=1:K
    c_continuity = [c_continuity; state(k).evaluate(1) - state(k+1).evaluate(0)];
end

L_fn = casadi.Function('L', {x.evaluate, u.evaluate}, {J_integrand.evaluate});

% Sample signal to integrate
clear L
L(K) = yop.collocation_polynomial();
for k=1:K
    l_k = [];
    for r=1:d_x+1
        x_kr = state(k).evaluate(tau(r));
        u_kr = control(k).evaluate(tau(r));
        l_k = [l_k, L_fn(x_kr, u_kr)];
    end
    L(k).init(points, d_x, l_k, h*[(k-1) k]);
end

% Integrate signal
J = 0;
for k=1:K
    J = J + L(k).integrate.evaluate(1);
end


lb_x = -inf(size(w_x));
ub_x =  inf(size(w_x));
ub_x(1:2:end) = 1/9;
lb_x(1:2) = [0; 1];
ub_x(1:2) = [0; 1];
lb_x(end-1:end) = [0; -1];
ub_x(end-1:end) = [0; -1];

lb_u = -inf(size(w_u));
ub_u =  inf(size(w_u));

lb_t0 = 0;
ub_t0 = 0;
lb_tf = 1;
ub_tf = 1;

w = [t_0.evaluate; t_f.evaluate; w_x; w_u];
w_lb = [lb_t0; lb_tf; lb_x; lb_u];
w_ub = [ub_t0; ub_tf; ub_x; ub_u];

g = [c_ode; c_continuity];
g_ub = zeros(size(g));
g_lb = g_ub;

nlp = struct;
nlp.x = w;
nlp.f = J;
nlp.g = g;
solver = casadi.nlpsol('yoptimizer', 'ipopt', nlp);
solution = solver('x0', zeros(size(w)), 'lbx', w_lb, 'ubx', w_ub, 'lbg', g_lb, 'ubg', g_ub);

w_opt = full(solution.x);


%%
t_x = [];
for k=1:K
    t_k = h*(k-1);
    for r=1:d_x+1
        t_x = [t_x, t_k + h*tau(r)];
    end
end
t_x = [t_x, t_f.evaluate];
t_xfun = casadi.Function('t', {t_0.evaluate, t_f.evaluate}, {t_x});

t_u = [];
for k=1:K
    t_k = h*(k-1);
    for r=1:d_u+1
        t_u = [t_u, t_k + h*tau_u(r)];
    end
end
t_u = [t_u, t_f.evaluate];
t_ufun = casadi.Function('t', {t_0.evaluate, t_f.evaluate}, {t_u});

x_fun = casadi.Function('x', {w}, {w_x});
u_fun = casadi.Function('u', {w}, {w_u});
u_end = casadi.Function('u_end', {w}, {control(K).evaluate(1)});
%%
nx = size(x,1);
t_0opt = w_opt(1);
t_fopt = w_opt(2);
x_opt = full(x_fun(w_opt));
x1_opt = x_opt(1:2:end);
x2_opt = x_opt(2:2:end);
u_opt = full(u_fun(w_opt));
u_opt(end+1) = full(u_end(w_opt));

t_xopt = full(t_xfun(t_0opt, t_fopt));
t_uopt = full(t_ufun(t_0opt, t_fopt));


figure(1); 
subplot(311); hold on;
plot(t_xopt, x1_opt)
subplot(312); hold on;
plot(t_xopt, x2_opt)
subplot(313); hold on;
stairs(t_uopt, u_opt)




















