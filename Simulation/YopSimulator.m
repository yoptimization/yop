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
classdef YopSimulator < handle
    properties
        Systems
        Connections
        Independent
        State
        Algebraic
        Parameter
        Variables
    end
    methods
        function obj = YopSimulator(varargin)
            
            ip = inputParser;
            ip.FunctionName = 'YopSimulator';
            ip.PartialMatching = false;
            ip.KeepUnmatched = false;
            ip.CaseSensitive = true;
            
            d = yopDefaultVariables;
            
            yopCustomPropertyNames;
            ip.addParameter(userSystems, []);
            ip.addParameter(userConnections, []);
            
            ip.parse(varargin{:});
            
            obj.Systems = ip.Results.(userSystems);
            obj.Connections = ip.Results.(userConnections);            
            
            obj.Independent = YopSimulationVariable(YopIndependentVariable.getIndependentVariable);
            obj.State = YopSimulationVariable.initializeArray(vertcat(obj.Systems.State));
            obj.Algebraic = YopSimulationVariable.initializeArray([vertcat(obj.Systems.Algebraic); vertcat(obj.Systems.Control); vertcat(obj.Systems.ExternalInput)]);
            obj.Parameter = YopSimulationVariable.initializeArray(vertcat(obj.Systems.Parameter));
            obj.Variables = [obj.Independent; obj.State; obj.Algebraic; obj.Parameter];
            
        end
        
        function setInitialValue(obj, variable, value)
            for n=1:length(variable)
                for k=1:length(obj.Variables)
                    if obj.Variables(k).depends_on(variable(n))
                        obj.Variables(k).InitialValue = value(n);
                        break;
                    end
                end
            end
        end
        
        function simulationResults = simulate(obj, varargin)
            import casadi.*
            
            dae = struct;
            dae.t = obj.Independent.Variable;
            dae.x = vertcat(obj.State.Variable);
            dae.z = vertcat(obj.Algebraic.Variable);
            dae.p = vertcat(obj.Parameter.Variable);
            dae.ode = vertcat(obj.Systems.DifferentialEquation);
            dae.alg = [vertcat(obj.Systems.AlgebraicEquation); vertcat(obj.Connections.Connection)];
            
            options = [];
            k = 1;
            while k < length(varargin)
                if strcmp(varargin{k}, 'initialValue')
                    obj.setInitialValue(varargin{k+1}, varargin{k+2})
                    k = k+3;
                else
                    options = [options, varargin(k)];
                    k = k+1;
                end
            end
            
            x0 = vertcat(obj.State.InitialValue);
            z0 = vertcat(obj.Algebraic.InitialValue);
            p  = vertcat(obj.Parameter.InitialValue);

            simulatorOptions = YopSimulatorOptions(options{:});
            options = simulatorOptions.getOptions;
            
            idasIntegrator = integrator('IdasIntegrator', 'idas', dae, options);
            res = idasIntegrator('x0', x0, 'z0', z0, 'p', p);         
            
            simulationResults = YopSimulationResults(dae, options.grid, full(res.xf), full(res.zf), p, idasIntegrator.stats);
            
        end        
    end
end





















