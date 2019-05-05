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
classdef YopOcpResults < handle
    properties
        Variables
        NumericalResults
        NlpSolution
        Stats
    end
    methods
        function obj = YopOcpResults()
        end
        
        function parseResults(obj, ocp, stats, nlpSolution)
            
            obj.setStats(stats);
            obj.setNlpSolution(nlpSolution);
            
            for k=1:length(obj)
                
                phase_fun = casadi.Function('w', {ocp.getNlpVariable}, {ocp(k).getNlpVariable});
                wk = phase_fun(nlpSolution.x);
                
                J = full(nlpSolution.f)/ocp(k).Objective.Weight;
                                                
                t_fun = casadi.Function('t', {ocp(k).NlpVector.NlpVariable}, ...
                    {ocp(k).NlpVector.Independent.getColumn(1)});
                
                x_fun = casadi.Function('x', {ocp(k).NlpVector.NlpVariable}, ...
                    {ocp(k).NlpVector.State.getColumn(1)});
                
                z_fun = casadi.Function('z', {ocp(k).NlpVector.NlpVariable}, ...
                    {ocp(k).NlpVector.Algebraic.getColumn(1)});
                
                u_fun = casadi.Function('u', {ocp(k).NlpVector.NlpVariable}, ...
                    {[ocp(k).NlpVector.Control.getColumn(1), ocp(k).NlpVector.Control.get('end', 1)]});
                
                p_fun = casadi.Function('p', {ocp(k).NlpVector.NlpVariable}, ...
                    {ocp(k).NlpVector.Parameter.getColumn(1)});
                
                t_opt = ocp(k).Independent.descale(...
                    full( t_fun(wk) ) ...
                    );
                
                x_opt = ocp(k).State.descale( ...
                    full( x_fun(wk) ) ...
                    );
                
                z_opt = ocp(k).Algebraic.descale( ...
                    full( z_fun(wk) ) ...
                    );
                
                u_opt = ocp(k).Control.descale( ...
                    full( u_fun(wk) ) ...
                    );
                
                p_opt = ocp(k).Parameter.descale( ...
                    full( p_fun(wk) ) ...
                    );
                
                lam_t = ocp(k).Independent.descale(...
                    full( t_fun(wk) )...
                    );
                
                lam_x = ocp(k).State.descale( ...
                    full( x_fun(wk) )...
                    );
                
                lam_z = ocp(k).Algebraic.descale( ...
                    full( z_fun(wk) ) ...
                    );
                
                lam_u = ocp(k).Control.descale( ...
                    full( u_fun(wk) ) ...
                    );
                
                lam_p =  ocp(k).Parameter.descale( ...
                    full( p_fun(wk) )...
                    );
                
                obj(k).Variables.Independent = YopIndependentVariable.getIndependentVariable;
                obj(k).Variables.State     = ocp(k).getSystemStates;
                obj(k).Variables.Algebraic = ocp(k).getSystemAlgebraics;
                obj(k).Variables.Control   = ocp(k).getSystemControls;
                obj(k).Variables.Parameter = ocp(k).getSystemParameters;
                obj(k).NumericalResults.Objective = J;
                obj(k).NumericalResults.Independent = t_opt;
                obj(k).NumericalResults.State     = x_opt;
                obj(k).NumericalResults.Algebraic = z_opt;
                obj(k).NumericalResults.Control   = u_opt;
                obj(k).NumericalResults.Parameter = p_opt;
                obj(k).NumericalResults.LagrangeIndependent = lam_t;
                obj(k).NumericalResults.LagrangeState = lam_x;
                obj(k).NumericalResults.LagrangeAlgebraic = lam_z;
                obj(k).NumericalResults.LagrangeControl = lam_u;
                obj(k).NumericalResults.LagrangeParameter = lam_p;
            end
            
        end
        
        function setStats(obj, stats)
            for k=1:length(obj)
                obj(k).Stats = stats;
            end
        end
        
        function setNlpSolution(obj, nlpSolution)
            for k=1:length(obj)
                obj(k).NlpSolution = nlpSolution;
            end
        end
        
        function args = input(obj)
            args = {obj.Variables.Independent, obj.Variables.State, ...
                obj.Variables.Algebraic, obj.Variables.Control, ...
                obj.Variables.Parameter};
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
            expressionFunction = casadi.Function('plotFun', obj.input, {signalExpression});
            y = full(expressionFunction( ...
                obj.NumericalResults.Independent, ...
                obj.NumericalResults.State, ...
                obj.NumericalResults.Algebraic, ...
                obj.NumericalResults.Control, ...
                obj.NumericalResults.Parameter ...
                ));
        end
        
        function p = parameter(obj, expression)
           getter = casadi.Function('p', {obj.Variables.Parameter}, {expression});
           p = full(getter(obj.NumericalResults.Parameter));
        end
        
        function value = converged(obj) 
            value = obj.Stats.success;
        end
    end
end
   
    