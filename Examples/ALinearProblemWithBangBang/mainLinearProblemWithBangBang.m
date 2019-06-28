%% A Linear Problem With Bang Bang Control
% Create the Yop system
sys = YopSystem('states', 2, 'controls', 1);
% Symbolic variables
t = sys.t;
x = sys.x;
u = sys.u;

% Model
xdot = [x(2); u];
sys.set('ode', xdot)

% Formulate optimal control problem
ocp = YopOcp();
ocp.min({ t_f( t ) });
xf = [300; 0];
ocp.st(...
     'systems', sys, ...
     ... % Initial conditions
    {  0  '==' t_0(  t   )   }, ...
    {  0  '==' t_0( x(1) )   }, ...
    {  0  '==' t_0( x(2) )   }, ...
    ... % Constraints
    {-inf '<=' x(1) '<=' inf }, ...
    {-inf '<=' x(2) '<=' inf }, ...
    { -2  '<='  u   '<=' 1   }, ...
    ... % Final conditions
    { 300 '==' t_f( x(1) )   }, ...
    {  0  '==' t_f( x(2) )   } ...
    );

% Solving the OCP
sol = ocp.solve('controlIntervals', 30);

%% Plot the results
figure(1)
subplot(211); hold on
sol.plot(sys.t, sys.x(1))
xlabel('Time')
ylabel('Position')

subplot(212); hold on
sol.plot(sys.t, sys.x(2))
xlabel('Time')
ylabel('Velocity')

figure(2); hold on
sol.stairs(sys.t, sys.u)
xlabel('Time')
ylabel('Acceleration (Control)')
