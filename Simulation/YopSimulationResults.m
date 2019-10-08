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
classdef YopSimulationResults < handle
    properties
        NumericalResults
        Variables
        Stats
    end
    methods
        function obj = YopSimulationResults(dae, independentVariable, state, algebraicVariable, parameter, stats)
            
            results.Independent = independentVariable;
            results.State = state;
            results.Algebraic = algebraicVariable;
            results.Parameter = parameter;
            
            obj.NumericalResults = results;
            obj.Variables.Independent = dae.t;
            obj.Variables.State = dae.x;
            obj.Variables.Algebraic = dae.z;
            obj.Variables.Parameter = dae.p;
            
            obj.Stats = stats;
            
        end
        
        function varargout = plot3(obj, xSignal, ySignal, zSignal, varargin)
            x = obj.signal(xSignal);
            y = obj.signal(ySignal);
            z = obj.signal(zSignal);
            h = plot3(x, y, z, varargin{:});
            if nargout > 0
                varargout{1} = h;
            end            
        end
        
        function varargout = plot(obj, xSignal, ySignal, varargin)     
            h = obj.superPlot(@ plot, xSignal, ySignal, varargin{:});
            if nargout > 0
                varargout{1} = h;
            end
            
        end
        
        function varargout = stairs(obj, xSignal, ySignal, varargin)
            h = obj.superPlot(@ stairs, xSignal, ySignal, varargin{:});
            if nargout > 0
                varargout{1} = h;
            end
        end
        
        function h = superPlot(obj, plotFunction, xSignal, ySignal, varargin)
            x = obj.signal(xSignal);
            y = obj.signal(ySignal);
            h = plotFunction(x, y, varargin{:});
            
        end
        
        function y = signal(obj, signalExpression)
            args = {obj.Variables.Independent, obj.Variables.State, obj.Variables.Algebraic, obj.Variables.Parameter};
            expressionFunction = casadi.Function('y', args, {signalExpression});
            y = full(expressionFunction( ...
                obj.NumericalResults.Independent, ...
                obj.NumericalResults.State, ...
                obj.NumericalResults.Algebraic, ...
                obj.NumericalResults.Parameter ...
                ));
        end
        
        function p = parameter(obj, expression)
           getter = casadi.Function('p', {obj.Variables.Parameter}, {expression});
           p = full(getter(obj.NumericalResults.Parameter));
        end
    
    end
end