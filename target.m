%% Yop
import yop.*

% variable - tidskontinuerlig
% parameter - parameter som ska optimeras
% constant - konstant vars värde man kan ändra mellan körningar

t_0 = parameter('t_0');
t_f = parameter('t_f');
t = variable('t');
x = variable('x', 2);
u = variable('u');
l = constant('l', 1);
alpa = signal('alpha', @(t) f(t));

[ode, cart] = trolleyModel(ts, xs, us);

ocp = optimization_problem('t0', t_0, 'tf', t_f, 'state',  x, 'control', u);

ocp.minimize( 1/2*integral( cart.acceleration^2 ) );

ocp.subject_to( ...
    dot(x) == ode, ...
    alg(0) == ae, ...
    t0(cart.position) == 0, ...
    t0(cart.speed) == 1, ...
    tf(cart.position) == 0, ...
    tf(cart.speed) == 1, ...
    cart.position <= l, ...
    0 == t_0 <= t_f == 1 ...
    );

l.set_value(2);

res = ocp.solve(...
    'directCollocation', ...
    'segements', 100, ...
    'points', 'legendre', ...
    'degree', 5, ...
    'initialGuess', sim_res ...
    );

l.set_value(3);
res2 = ocp.resolve();

figure(1)
subplot(211)
res.plot(t, x(1));
subplot(212)
res.plot(t, x(2));

figure(2)
res.plot(t, u);

%%
simulator = yop.simulator('t0', t_0, 'tf', t_f, 'state', x, 'algebraic', z);

simulator.problem(t_0==0, t_f==1, dot(x)==ode, t0(x)==x0);

simulator.steps = 100;
simulator.reltol = 1e-4;
simulator.integrator = 'ode15s';
sim_res = simulator.simulate();

