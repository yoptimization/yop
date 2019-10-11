%% Yop
import Yop.*

t = variable('t'); x = variable('x', 2); u = variable('u');
[ode, cart] = trolleyModel(ts, xs, us);

[sensitivityOde, sensitivityVariables] = addParameterSensitivity(ode);

ocp = optimizationProblem('states',  x, 'controls', u);

ocp.minimize( 1/2*integral(cart.acceleration^2) );

ocp.subjectTo( ...
    dot(x) == ode, ...
    cart.position(t0) == 0, ...
    cart.speed(t0) == 1, ...
    cart.position(tf) == 0, ...
    cart.speed(tf) == 1, ...
    cart.position <= 1/9, ...
    0 == t0 <= tf == 1 ...
    );

res=ocp.solve('directCollocation', 'segements', 100, 'points', 'legendre', 'degree', 5);

figure(1)
subplot(211)
res.plot(t, x(1));
subplot(212)
res.plot(t, x(2));

figure(2)
res.plot(t, u);