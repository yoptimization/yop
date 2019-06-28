%% -------- Transient optimization of Diesel-electric Powertrain ----------
%
%  Copyright 2019, Viktor Leek
%                  viktor.leek@liu.se
%
% -------------------------------------------------------------------------
% Problem taken from:
% AN OPTIMAL CONTROL BENCHMARK: TRANSIENT OPTIMIZATIONOF A DIESEL-ELECTRIC
%   POWERTRAIN
%
% Formulated by: Martin Sivertsson and Lars Eriksson
% Publication:
%        http://www.fs.isy.liu.se/Publications/Articles/SIMS_14_MS_LE_2.pdf
%
% Software available at:
%        http://www.fs.isy.liu.se/Software/LiU-D-El_and_Benchmark/
%
% -------------------------------------------------------------------------
%% System of interest
genset = YopSystem('states', 5, 'controls', 3, 'model', @gensetModel);

time         = genset.t;
engine       = genset.y.engine;
compressor   = genset.y.compressor;
intake       = genset.y.intake;
cylinder     = genset.y.cylinder;
exhaust      = genset.y.exhaust;
turbine      = genset.y.turbine;
wastegate    = genset.y.wastegate;
turbocharger = genset.y.turbocharger;
generator    = genset.y.generator;

%% Initial Guess
% An engine speed controller
desiredEngineSpeed = 1500; % rpm
controller = YopSystem('states', 1, 'externals', 3, 'parameters', 2, 'model', @speedController);

% A ramp for controlling the generator power output
rampStartingPoint = 1;
rampFinishPoint = 4;
preRampValue = 0;
postRampValue = 120e3;
rampParameters = [rampStartingPoint; rampFinishPoint; preRampValue; postRampValue];

demand = YopSystem('model', @(t) powerDemand(t, rampParameters) );

% Connect the systems
closed = 0;
c1 = YopConnection(controller.y.engineSpeedInput, engine.speed);
c2 = YopConnection(controller.y.desiredEngineSpeedInput, rpm2rad(desiredEngineSpeed));
c3 = YopConnection(controller.y.fuelLimiterInput, cylinder.fuelLimiter);
c4 = YopConnection(controller.y.controlSignal, cylinder.fuelInjection);
c5 = YopConnection(wastegate.control, closed);
c6 = YopConnection(generator.power, demand.y.power);

% Create a simulator
simulator = YopSimulator(...
    'systems', [genset; controller; demand], ...
    'connections', [c1; c2; c3; c4; c5; c6] ...
    );

% Simulate the system
res = simulator.simulate(...
    'grid', linspace(0, 7, 1000), ...
    'printStats', true, ...
    'initialValue', engine.speed, rpm2rad(800), ...
    'initialValue', intake.pressure, 1.0143e+05, ...
    'initialValue', exhaust.pressure, 1.0975e+05, ...
    'initialValue', turbocharger.speed, 2.0502e+03, ...
    'initialValue', generator.energy, 0, ...
    'initialValue', controller.y.integralState, 0, ...
    'initialValue', controller.y.proportionalGain, 2, ...
    'initialValue', controller.y.integralGain, 1 ...
    );

%% Plot initial guess
% States
figure(1)
ax1 = subplot(511); hold on; grid on
res.plot(time, rad2rpm(engine.speed))
title('Engine speed [rpm]')

ax2 = subplot(512); hold on; grid on
res.plot(time, intake.pressure*1e-5)
title('Intake manifold pressure [bar]')

ax3 = subplot(513); hold on; grid on
res.plot(time, exhaust.pressure*1e-5)
title('Exhaust manifold pressure [bar]')

ax4 = subplot(514); hold on; grid on
res.plot(time, rad2rpm(turbocharger.speed)*1e-3)
title('Turbo speed [krpm]')

ax5 = subplot(515); hold on; grid on
res.plot(time, generator.energy*1e-3)
title('Generator energy output [kJ]')

% Controls
figure(2)
ax6 = subplot(311); hold on; grid on
res.plot(time, cylinder.fuelInjection);
res.plot(time, cylinder.fuelLimiter, 'r')
title('Fuel injection [mg/cycle/cylinder]')
legend('u_{fuel}', 'smoke limiter', 'Location', 'South')

ax7 = subplot(312); hold on; grid on
res.plot(time, wastegate.control);
title('Wastegate range[0,1]')

ax8 = subplot(313); hold on; grid on
res.plot(time, generator.power*1e-3);
title('Generator power [kW]')

linkaxes([ax1,ax2,ax3,ax4,ax5,ax6,ax7,ax8],'x')


%% Optimal control


ocp = YopOcp();
ocp.min({ timeIntegral( cylinder.fuelMassflow ) })
ocp.st(...
    'systems', genset, ...
    { 1.1   '<=' t_f( time ) '<=' 1.4   }, ...
    ... Initial conditions
    { rpm2rad(800) '==' t_0( engine.speed      )  }, ...
    { 1.0143e+05   '==' t_0( intake.pressure   )  }, ...
    { 1.0975e+05   '==' t_0( exhaust.pressure  )  }, ...
    { 2.0502e+03   '==' t_0( turbocharger.speed)  }, ...
    {     0        '==' t_0( generator.energy  )  }, ...
    {  closed      '==' t_0( wastegate.control )  }, ...
    ... Terminal conditions
    { 100e3 '==' t_f( generator.power  ) }, ...
    { 100e3 '==' t_f( generator.energy ) }, ...
    {  0    '==' t_f( genset.ode(1:4)  ) }, ... % Stationarity
    ... Box constraints
    { rpm2rad(800) '<=' engine.speed           '<=' rpm2rad(2500) }, ...
    {  8.0889e+04  '<=' intake.pressure        '<=' 350000        }, ...
    {  9.1000e+04  '<=' exhaust.pressure       '<=' 400000        }, ...
    {     500      '<=' turbocharger.speed     '<=' 15000         }, ...
    {      0       '<=' generator.energy       '<=' 3000000       }, ...
    {      0       '<=' cylinder.fuelInjection '<=' 150           }, ...
    {      0       '<=' wastegate.control      '<=' 1             }, ...
    {      0       '<=' generator.power        '<=' 100e3         }, ...
    ... Path constraints
    { turbine.BSRMin '<=' turbine.BSR '<=' turbine.BSRMax         }, ...
    {  0 '>=' (engine.power - engine.powerLimit(1))               }, ...
    {  0 '>=' (engine.power - engine.powerLimit(2))               }, ...
    {  0 '>=' (cylinder.fuelToAirRatio - 1/cylinder.lambdaMin)    }, ...
    {  0 '>=' (compressor.pressureRatio - compressor.surgeline)   } ...
    );

% Scale problem
ocp.scale('objective', 1e3);

ocp.scale('variable', engine.speed,      'weight', rpm2rad(1e-3))
ocp.scale('variable', intake.pressure,   'weight', 1e-5)
ocp.scale('variable', exhaust.pressure,  'weight', 1e-5)
ocp.scale('variable', turbocharger.speed,'weight', 1e-3)
ocp.scale('variable', generator.energy,  'weight', 1e-5)

ocp.scale('variable', cylinder.fuelInjection, 'weight', 1e-2)
ocp.scale('variable', wastegate.control, 'weight', 1e-5)
ocp.scale('variable', generator.power,   'weight', 1e-5)

% Solve
sol = ocp.solve( ...
    'initialGuess', res, ...
    'controlIntervals', 75, ...
    'collocationPoints', 'radau', ...
    'polynomialDegree', 3, ...
    'ipopt', struct('acceptable_tol', 1e-7) ...
    );

%% Plot optimal control
% States
figure(1)
ax1 = subplot(511); hold on; grid minor
sol.plot(time, rad2rpm(engine.speed))
title('Engine speed [rpm]')

ax2 = subplot(512); hold on; grid minor
sol.plot(time, intake.pressure*1e-5)
title('Intake manifold pressure [bar]')

ax3 = subplot(513); hold on; grid minor
sol.plot(time, exhaust.pressure*1e-5)
title('Exhaust manifold pressure [bar]')

ax4 = subplot(514); hold on; grid minor
sol.plot(time, rad2rpm(turbocharger.speed)*1e-3)
title('Turbo speed [krpm]')

ax5 = subplot(515); hold on; grid minor
sol.plot(time, generator.energy*1e-3)
title('Generator energy output [kJ]')

% Controls
figure(2)
ax6 = subplot(311); hold on; grid minor
sol.stairs(time, cylinder.fuelInjection);
sol.plot(time, cylinder.fuelLimiter, 'r')
title('Fuel injection [mg/cycle/cylinder]')
legend('u_{fuel}', 'smoke limiter', 'Location', 'South')



ax7 = subplot(312); hold on; grid minor
sol.stairs(time, wastegate.control);
title('Wastegate range[0,1]')

ax8 = subplot(313); hold on; grid minor
sol.stairs(time, generator.power*1e-3);
title('Generator power [kW]')

linkaxes([ax1,ax2,ax3,ax4,ax5,ax6,ax7,ax8],'x')