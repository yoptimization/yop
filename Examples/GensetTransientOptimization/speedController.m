function [stateDerivative, y] = speedController(time, integralState, external, parameters)
%% A genset engine speed controller ---------
%  PI-controller with wind-up (!)
%
%  Author: Viktor Leek, viktor.leek@liu.se
%  Copyright 2019
%
%--------------------------------------------
engineSpeed = external(1); % Engine speed
desiredEngineSpeed = external(2); % Desired engine speed
fuelLimiter = external(3); % Smoke limiter

% Controller parameters
kp = parameters(1);
ki = parameters(2);

error = desiredEngineSpeed - engineSpeed;

% Feedback term
proportionalControl = kp*error;
integralControl = ki*integralState;
control = proportionalControl + integralControl;

% derivative of the integral
stateDerivative = error;

% Saturate contol signal
saturatedControl = if_else(control > fuelLimiter, fuelLimiter, control);

% Absolute limit
controlUpperBounded = if_else(saturatedControl < 0, 0, saturatedControl);
controlUpperLowerBounded = if_else(controlUpperBounded > 150, ...
                                    150, ...
                                    controlUpperBounded ...
                                   );

% Store output as a struct:
y.engineSpeedInput = external(1);
y.desiredEngineSpeedInput = external(2);
y.fuelLimiterInput = external(3);
y.proportionalGain = parameters(1);
y.integralGain = parameters(2);
y.integralState = integralState;
y.controlSignal = controlUpperLowerBounded; % Engine control signal
y.unsaturatedControl = control; % unconstrained control signal
y.error = error; % Error
y.integralControl = integralControl; % integral part
y.proportionalControl = proportionalControl; % proportional part
y.fuelLimiter = fuelLimiter; % Smoke limiter
y.externalInput = external;
end