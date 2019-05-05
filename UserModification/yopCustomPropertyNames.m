% Copyright 2019, Viktor Leek
%
% This file is part of Yop.
%
% Yop is free software: you can redistribute it and/or modify it
% under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or any
% later version.
% Yop is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
% Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Yop.  If not, see <https://www.gnu.org/licenses/>.
% -------------------------------------------------------------------------
%% Custom property names

% System declaration
userTimeDependent = 'timeDependent';
userNumberOfStates = 'states';
userNumberOfAlgebraics = 'algebraics';
userNumberOfControls = 'controls';
userNumberOfExternalInputs = 'externals';
userNumberOfParameters = 'parameters';
userHasSignalOutput = 'signalOutput';
userModelHandle = 'model';

% System inputs
userIndependentVariableProperty = 't';
userStateProperty = 'x';
userAlgebraicVariableProperty = 'z';
userControlProperty = 'u';
userParameterProperty = 'p';
userExternalInputProperty = 'w';

% System outputs
userOrdinaryDifferentialEquationProperty = 'ode';
userAlgebraicEquationProperty = 'ae';
userSignalOutputProperty = 'y';

% Simulation

% Simulation and Optimal control
userInitialState = 'x0';
userFinalState = 'xf';
userInitialAlgebraic = 'z0';
userFinalAlgebraic = 'zf';
userInitialControl = 'u0';
userFinalControl = 'uf';

% Optimal Control Problems
userIntegralCost = 'L';
userTerminalCost = 'E';
userSystem = 'system';
userSystems = 'systems';
userConnections = 'connections';

% Constraints and Nominal values
userFinalIndependentUpperBound = 'tf_max';
userFinalIndependentLowerBound = 'tf_min';
userFinalIndependent = 'tf';
userInitialIndependentUpperBound = 't0_max';
userInitialIndependentLowerBound = 't0_min';
userInitialIndependent = 't0';
userStateUpperBound = 'x_max';
userStateLowerBound = 'x_min';
userStateInitialUpperBound = 'x0_max';
userStateInitialLowerBound = 'x0_min';
userStateFinalUpperBound = 'xf_max';
userStateFinalLowerBound = 'xf_min';
userAlgebraicUpperBound = 'z_max';
userAlgebraicLowerBound = 'z_min';
userControlUpperBound = 'u_max';
userControlLowerBound = 'u_min';
userControlInitialUpperBound = 'u0_max';
userControlInitialLowerBound = 'u0_min';
userControlFinalUpperBound = 'uf_max';
userControlFinalLowerBound = 'uf_min';
userParameterUpperBound = 'p_max';
userParameterLowerBound = 'p_min';
userFixedParameter = 'p';
userInequality = 'h';
userInequalityInitial = 'hi';
userInequalityFinal = 'hf';
userEquality = 'g';
userEqualityInitial = 'gi';
userEqualityFinal = 'gf';
userNominalIndependent = 'tf_nom';
userNominalState = 'x_nom';
userNominalAlgebraic = 'z_nom';
userNominalControl = 'u_nom';
userNominalParameter = 'p_nom';




