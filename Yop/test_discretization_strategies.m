%% Diskretisera genom att kontrollera value för x, u
yop.options.set_symbolics('symbolic math');

% t_0 = yop.parameter('t0');
% t_f = yop.parameter('tf');
% t = yop.variable('t');
% x = yop.variable('x', [2,1]);
% u = yop.variable('u');
% 
% dx = trolleyModel(t, x, u);

% Parametrisera signalerna

%% lagrange polynomial
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
plot(t, lp.integrate.evaluate(t), 'x')
legend('1/3 t.^3', '1/4 t.^4', 'lp_1', 'lp_2')
title('integration')

%% Collocation polynomial
% Approximate the t^2 and t^3  at the specified timepoints using a
%  second order collocation polynomial.
timepoints = [1,2,3];
analytical_values = @(t) [t.^2; t.^3];
analytical_derivative = @(t) [2*t; 3*t.^2];
analytical_integral = @(t) [t.^3/3; t.^4/4];

t_0 = 1;
t_f = 3;
h = t_f-t_0; 
points = 'legendre';
deg = 2;

tau = yop.collocation_polynomial.collocation_points(points, deg);
values = analytical_values(t_0 + tau*h);

cp = yop.collocation_polynomial();
cp.init(points, deg, values, [t_0, t_f]);

t = linspace(t_0, t_f, 21);
figure(1); hold on
plot(t, analytical_values(t))
plot(t, cp.evaluate((t-t_0)./h), 'x')
legend('t^2', 't^3', 'cp_1', 'cp_2')
title('Polynomial approximation')

figure(2); hold on
plot(t, analytical_derivative(t))
plot(t, cp.differentiate.evaluate((t-t_0)./h), 'x')
legend('2*t', '3*t.^2', 'cp_1', 'cp_2')
title('differentiation')

figure(3); hold on
plot(t, analytical_integral(t))
plot(t, cp.integrate.evaluate((t-t_0)./h), 'x')
legend('1/3 t.^3', '1/4 t.^4', 'cp_1', 'cp_2')
title('integration')























