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
classdef YopNlpVariableInitializer < handle
    properties
        IndependentVariable
        StateVariable
        AlgebraicVariable
        ControlVariable
        ParameterVariable
        IndependentValues
        StateValues
        AlgebraicValues
        ControlValues
        ParameterValues
        StateFunction
        AlgebraicFunction
        ControlFunction
    end
    methods
        function obj = YopNlpVariableInitializer(variables, values)
            obj.IndependentVariable = YopIndependentVariable.getIndependentVariable;
            obj.StateVariable     = variables.State;
            obj.AlgebraicVariable = variables.Algebraic;
            obj.ControlVariable   = variables.Control;
            obj.ParameterVariable = variables.Parameter;
            obj.IndependentValues = values.Independent;
            obj.StateValues       = values.State;
            obj.AlgebraicValues   = values.Algebraic;
            obj.ControlValues     = values.Control;
            obj.ParameterValues   = values.Parameter;
            obj.StateFunction     = YopInterpolant(values.Independent, values.State);
            obj.AlgebraicFunction = YopInterpolant(values.Independent, values.Algebraic);
            obj.ControlFunction   = YopInterpolant(values.Independent, values.Control);
        end
        
        function t0 = independentInitial(obj)
            t0 = obj.IndependentValues(1);
        end
        
        function tf = independentFinal(obj)
            tf = obj.IndependentValues(end);
        end
        
        function x = state(obj, timepoint) 
            t = obj.evaluateTimepoint(timepoint);
            x = full(obj.StateFunction(t));    
        end
        
        function z = algebraic(obj, timepoint)
            t = obj.evaluateTimepoint(timepoint);
            z = full(obj.AlgebraicFunction(t));  
        end
        
        function u = control(obj, timepoint)
            t = obj.evaluateTimepoint(timepoint);
            u = full(obj.ControlFunction(t)); 
        end
        
        function p = parameter(obj)
            p = obj.ParameterValues;
        end
        
        function t = evaluateTimepoint(obj, timepoint)
            input = symvar(timepoint);
            t0 = obj.IndependentValues(1);
            tf = obj.IndependentValues(end);
            evaluator = casadi.Function('evaluator', input, {timepoint});
            if size(input) == 0
                t = [];
            elseif size(input) == 1
                t = full(evaluator(t0));
            else
                t = full(evaluator(t0, tf));
            end 
        end
        
        function y = signal(obj, signalExpression)
            args = {obj.IndependentVariable, obj.StateVariable, obj.AlgebraicVariable, obj.ControlVariable, obj.ParameterVariable};
            expressionFunction = casadi.Function('y', args, {signalExpression});
            y = full(expressionFunction(obj.IndependentValues, obj.StateValues, obj.AlgebraicValues, obj.ControlValues, obj.ParameterValues));
        end
    end
end