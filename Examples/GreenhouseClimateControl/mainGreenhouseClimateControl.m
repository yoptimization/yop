%% Greenhouse Climate Control, with external input
% Author: Dennis Edblom
sys = YopSystem('states', 2, 'controls', 1, ...
    'model', @greenhouseModel);
% Symbolic variables
t = sys.t;
x = sys.x;
u = sys.u;

%% Formulate optimal control problem
p4 = 4.55e-4;
p5 = 136.4;
tf = 48;

ocp = YopOcp();
ocp.min({ t_f(-p5*x(1)) '+' timeIntegral(p4*u) });
ocp.st(...
     'systems', sys, ...
     ... % Initial conditions
    { 0  '==' t_0(x(1)) }, ...
    { 10 '==' t_0(x(2)) }, ...
    ... % Constraints
    { 0  '<=' u '<=' 10 }, ...
    ... % Final conditions
    { tf '==' t_f(t)    } ...
    );
sol = ocp.solve('controlIntervals', 100);

%% Plot
% States, time and control
x1 = sol.signal(sys.x(1))';
x2 = sol.signal(sys.x(2))';
u = sol.signal(sys.u)';
t = sol.signal(sys.t)';

% External input for plots, comes from greenhouseModel
te = sys.y.te;
I  = sys.y.I;
T0 = sys.y.T0;

% Plot external inputs and control
figure(1);
plot(te,I./40,te,T0,t,u); axis([0 tf -1 30]);
xlabel('Time [h]');
ylabel('Heat input, temperatures & light');
legend('Light [W]','Outside temp. [oC]','Heat input [W]');
title('Optimal heating, outside temperature and light');

% Plot the optimal states
figure(2)
sf1=1200; sf3=60;
x3 = cumtrapz(t,p4*u); % Integral(pHc*u)
plot(t,[sf1*x1 x2 sf3*x3]); axis([0 tf -5 30]);
xlabel('Time [h]'); ylabel('states');
legend('1200*Dry weight [kg]','Greenhouse temp. [oC]','60*Integral(pHc*u dt) [J]');
title('Optimal system behavior and the running costs');
