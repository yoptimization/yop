function y = powerDemand(t, p)
%% ------- Generator power demand -----------
%
%  Author: Viktor Leek, viktor.leek@liu.se
%  Copyright 2019
%
%--------------------------------------------
import casadi.*

rampStartingPoint = p(1);
rampFinishPoint = p(2);
preRampValue = p(3);
postRampValue = p(4);

tVec     = [   0,   rampStartingPoint, rampFinishPoint, 1000];
valueVec = [preRampValue, preRampValue, postRampValue, postRampValue];
lookupTable = casadi.interpolant('power', 'linear', {tVec}, valueVec);

y.power = lookupTable(t);
y.rampStartingPoint = rampStartingPoint;
y.rampFinishPoint = rampFinishPoint;
y.preRampValue = preRampValue;
y.postRampValue = postRampValue;
end