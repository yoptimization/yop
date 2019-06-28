%% Goddard Rocket, Maximum Ascent
% Author: Dennis Edblom
sys = YopSystem(...
    'states', 3, ...
    'controls', 1, ...
    'model', @goddardModel ...
    );
time = sys.t;

% Rocket signals (symbolic)
rocket = sys.y.rocket;

% Formulate optimal control problem
ocp = YopOcp();
ocp.max({ t_f( rocket.height ) });
ocp.st(...
     'systems', sys, ...
     ... % Initial conditions
    {   0  '==' t_0( time )              }, ...
    {   1  '==' t_0( rocket.height   )   }, ...
    {   0  '==' t_0( rocket.speed    )   }, ...
    {   1  '==' t_0( rocket.fuelMass )   }, ...
    ... % Constraints
    {   0  '<=' t_f( time )     '<=' inf  }, ...
    {   1  '<=' rocket.height   '<=' inf  }, ...
    { -inf '<=' rocket.speed    '<=' inf  }, ...
    {  0.6 '<=' rocket.fuelMass '<='  1   }, ...
    {   0  '<=' rocket.thrust   '<=' 3.5  } ...
    );

% Solving the OCP
sol = ocp.solve('controlIntervals', 100);

% Plot the results
figure(1)
subplot(311); hold on
sol.plot(time, rocket.speed)
xlabel('Time')
ylabel('Speed')

subplot(312); hold on
sol.plot(time, rocket.height)
xlabel('Time')
ylabel('Height')

subplot(313); hold on
sol.plot(time, rocket.fuelMass)
xlabel('Time')
ylabel('Mass')

figure(2); hold on
sol.stairs(time, rocket.thrust)
xlabel('Time')
ylabel('Thrust (Control)')
