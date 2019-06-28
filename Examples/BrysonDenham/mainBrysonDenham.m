%% Bryson Denham
% Author: Dennis Edblom
% Create the Yop system
bdSystem = YopSystem(...
    'states', 2, ...
    'controls', 1, ...
    'model', @trolleyModel ...
    );

time = bdSystem.t;
trolley = bdSystem.y;

ocp = YopOcp();
ocp.min({ timeIntegral( 1/2*trolley.acceleration^2 ) });
ocp.st(...
    'systems', bdSystem, ...
    ... % Initial conditions
    {  0  '==' t_0( trolley.position ) }, ...
    {  1  '==' t_0( trolley.speed    ) }, ...
    ... % Terminal conditions
    {  1  '==' t_f( time ) }, ...
    {  0  '==' t_f( trolley.position ) }, ...
    { -1  '==' t_f( trolley.speed    ) }, ...
    ... % Constraints
    { 1/9 '>=' trolley.position        } ...
    );

% Solving the OCP
sol = ocp.solve('controlIntervals', 20);

%% Plot the results
figure(1)
subplot(211); hold on
sol.plot(time, trolley.position)
xlabel('Time')
ylabel('Position')

subplot(212); hold on
sol.plot(time, trolley.speed)
xlabel('Time')
ylabel('Velocity')

figure(2); hold on
sol.stairs(time, trolley.acceleration)
xlabel('Time')
ylabel('Acceleration (Control)')
