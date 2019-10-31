%% Diskretisera genom att kontrollera value för x, u
yop.options.set_symbolics('symbolic math');

t_0 = yop.parameter('t0');
t_f = yop.parameter('tf');
t = yop.variable('t');
x = yop.variable('x', [2,1]);
u = yop.variable('u');

dx = trolleyModel(t, x, u);

% Parametrisera signalerna




% Diskretisera genom att styra värden på value
% Approximate the t^2 and t^3  at the specified timepoints using a
% second order polynomial. Will result in an exact interpolation of t^2 but
% only an approximation of t^3
timepoints = [1,2,3]; % Three sample points results in 2:order polynomial.
analytical_values = @(t) [t.^2; t.^3];
analytical_derivative = @(t) [2*t; 3*t.^2];
analytical_integral = @(t) [t.^3/3; t.^4/4];

lp = yop.lagrange_polynomial();
lp.init(timepoints, analytical_values(timepoints));

t = 1:0.05:3;
figure(1); hold on
plot(t, analytical_values(t))
plot(t, lp.evaluate(t), 'x')
legend('t^2', 't^3', 'lp_1', 'lp_2')
title('Polynomial approximation')

figure(2); hold on
plot(t, analytical_derivative(t))
plot(t, lp.differentiate.evaluate(t), 'x')
legend('2*t', '3*t.^2', 'lp_1', 'lp_2')
title('differentiation')

figure(3); hold on
plot(t, analytical_integral(t))
plot(t, lp.integrate(0).evaluate(t), 'x')
legend('1/3 t.^3', '1/4 t.^4', 'lp_1', 'lp_2')
