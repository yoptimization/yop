%% Isoperimetric Constraint Problem
% Author: Dennis Edblom
sys = YopSystem('states', 2, 'controls', 1);
% Symbolic variables
t = sys.t;
x = sys.x;
u = sys.u;

% Model
xdot = [-sin(x(1)) + u; u^2];
sys.set('ode',xdot)

%% Formulate optimal control problem
ocp = YopOcp();
ocp.min({ LagrangeTerm( x(1) ) });
ocp.st(...
     'systems', sys, ...
     ... % Initial conditions
    { 0 '=='  t_0(  t   )    }, ...
    { 1 '=='  t_0( x(1) )    }, ...
    { 0 '=='  t_0( x(2) )    }, ...
    ... % Constraints
    { -4  '<='  u   '<='  4  }, ...
    { -10 '<=' x(1) '<=' 10  }, ...
    {-inf '<=' x(2) '<=' inf }, ...
    ... % Final conditions
    { 1  '<=' t_f(t)    '<=' 1 }, ...
    { 0  '<=' t_f(x(1)) '<=' 0 }, ...
    { 10 '==' t_f(x(2))        } ...
    );

sol = ocp.solve('controlIntervals', 30);

%% Plot the results
figure(1)
subplot(211); hold on
sol.plot(sys.t, sys.x(1))
xlabel('Time')
ylabel('x1')

subplot(212); hold on
sol.plot(sys.t, sys.x(2))
xlabel('Time')
ylabel('x2')

figure(2); hold on
sol.stairs(sys.t, sys.u)
xlabel('Time')
ylabel('u')
