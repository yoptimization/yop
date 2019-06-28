%% Goddard Rocket, Maximum Ascent
% Author: Dennis Edblom
% Create the Yop system
sys = YopSystem('states', 3, 'controls', 1, ...
    'model', @goddardRocketModel);
% Symbolic variables
time = sys.t;

% Rocket signals (symbolic)
rocket = sys.y.rocket;

m0 = 214.839;
mf = 67.9833;
Fm = 9.525515;
% Formulate optimal control problem
ocp = YopOcp();
ocp.max({ t_f( rocket.height ) });
ocp.st(...
     'systems', sys, ...
    ... % initial conditions
    {  0  '==' t_0(time)            }, ...
    {  0  '==' t_0(rocket.velocity) }, ...
    {  0  '==' t_0(rocket.height)   }, ...
    {  m0 '==' t_0(rocket.mass)     }, ...
    ... % Constraints
    { 100 '==' t_f( time)                   }, ...
    {  0  '<=' rocket.velocity     '<=' inf }, ...
    {  0  '<=' rocket.height       '<=' inf }, ...
    {  mf '<=' rocket.mass         '<=' m0  }, ...
    {  0  '<=' rocket.fuelMassFlow '<=' Fm  } ...
    );

% Solving the OCP
sol = ocp.solve('controlIntervals', 60);

%% Plot the results
figure(1)
subplot(311); hold on
sol.plot(time, rocket.velocity)
xlabel('Time')
ylabel('Velocity')

subplot(312); hold on
sol.plot(time, rocket.height)
xlabel('Time')
ylabel('Height')

subplot(313); hold on
sol.plot(time, rocket.mass)
xlabel('Time')
ylabel('Mass')

figure(2); hold on
sol.stairs(time, rocket.fuelMassFlow)
xlabel('Time')
ylabel('F (Control)')