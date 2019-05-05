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
classdef YopSystem < handle & dynamicprops
    properties
        Independent
        State
        Algebraic
        Control
        ExternalInput
        Parameter
        DifferentialEquation
        AlgebraicEquation
        Signal
    end
    methods

        function obj = YopSystem(varargin)
            
            ip = inputParser;
            ip.FunctionName = 'YopSystem';
            ip.PartialMatching = false;
            ip.KeepUnmatched = false;
            ip.CaseSensitive = true;
            
            defaultVariables = 0;
            
            yopCustomPropertyNames;
            ip.addParameter(userNumberOfStates, defaultVariables);
            ip.addParameter(userNumberOfAlgebraics, defaultVariables);
            ip.addParameter(userNumberOfControls, defaultVariables);
            ip.addParameter(userNumberOfExternalInputs, defaultVariables);
            ip.addParameter(userNumberOfParameters, defaultVariables);
            ip.addParameter(userModelHandle, []);
            
            ip.parse(varargin{:});
            
            obj.addDynamicProperties;
            obj.setIndependent;
            obj.setState(ip.Results.(userNumberOfStates));
            obj.setAlgebraic(ip.Results.(userNumberOfAlgebraics));
            obj.setControl(ip.Results.(userNumberOfControls));
            obj.setExternalInput(ip.Results.(userNumberOfExternalInputs));
            obj.setParameter(ip.Results.(userNumberOfParameters));
            if ~isempty(ip.Results.(userModelHandle))
                obj.setOutputs(ip.Results.(userModelHandle));
            end
                 
        end
        
        function t = getIndependent(obj)
            t = obj.Independent;
        end
        
        function x = getState(obj)
            x = obj.State;
        end
        
        function z = getAlgebraic(obj)
            z = obj.Algebraic;
        end
        
        function u = getControl(obj)
            u = obj.Control;
        end
        
        function w = getExternalInput(obj)
            w = obj.ExternalInput;
        end
        
        function p = getParameter(obj)
            p = obj.Parameter;
        end
        
        function ode = getDifferentialEquation(obj)
            ode = obj.DifferentialEquation;
        end
        
        function alg = getAlgebraicEquation(obj)
            alg = obj.AlgebraicEquation;
        end
        
        function y = getSignals(obj)
            y = obj.Signal;
        end
        
        function setIndependent(obj)
            yopCustomPropertyNames;
            obj.Independent = YopIndependentVariable.getIndependentVariable;
            obj.(userIndependentVariableProperty) = obj.Independent;
        end
        
        function setState(obj, states)
            yopCustomPropertyNames;
            arr = YopArray;
            arrayfun(@(k) arr.store(casadi.MX.sym([userStateProperty, num2str(k)])), 1:states);
            obj.State = arr.getElements;
            obj.(userStateProperty) = obj.State;
        end
        
        function setAlgebraic(obj, algebraics)
            yopCustomPropertyNames;
            arr = YopArray;
            arrayfun(@(k) arr.store(casadi.MX.sym([userAlgebraicVariableProperty, num2str(k)])), 1:algebraics);
            obj.Algebraic = arr.getElements;   
            obj.(userAlgebraicVariableProperty) = obj.Algebraic;
        end
        
        function setControl(obj, controls)
            yopCustomPropertyNames;
            arr = YopArray;
            arrayfun(@(k) arr.store(casadi.MX.sym([userControlProperty, num2str(k)])), 1:controls);
            obj.Control = arr.getElements;
            obj.(userControlProperty) = obj.Control;
        end
        
        function setExternalInput(obj, externalInputs)
            yopCustomPropertyNames;
            arr = YopArray;
            arrayfun(@(k) arr.store(casadi.MX.sym([userExternalInputProperty, num2str(k)])), 1:externalInputs);
            obj.ExternalInput = arr.getElements;
            obj.(userExternalInputProperty) = obj.ExternalInput;
        end
        
        function setParameter(obj, parameters)
            yopCustomPropertyNames;
            arr = YopArray;
            arrayfun(@(k) arr.store(casadi.MX.sym([userParameterProperty, num2str(k)])), 1:parameters);
            obj.Parameter = arr.getElements;
            obj.(userParameterProperty) = obj.Parameter;
        end
        
        function setDifferentialEquation(obj, ode)
            yopCustomPropertyNames;
            obj.DifferentialEquation = ode;
            obj.(userOrdinaryDifferentialEquationProperty) = ode;
        end
        
        function setAlgebraicEquation(obj, alg)
            yopCustomPropertyNames;
            obj.AlgebraicEquation = alg;
            obj.(userAlgebraicEquationProperty) = alg;
        end
        
        function setSignal(obj, y)
            yopCustomPropertyNames;
            obj.Signal = y;
            obj.(userSignalOutputProperty) = obj.Signal;
        end
        
        function setOutputs(obj, model)
            
            input = obj.getModelInput;
            nx = obj.numberOfStates;
            nz = obj.numberOfAlgebraics;
            
            if nx > 0 && nz > 0
                expectedArguments = 2;
            elseif nx > 0
                expectedArguments = 1;
            elseif nz > 0
                expectedArguments = 1;
            else
                expectedArguments = 1;
            end
            
            na = YopNargout(model, input, expectedArguments);            
            
            
            if nx==0  && nz==0  && na >= 1
                y = model(input{:});
                obj.setSignal(y);
                
            elseif nx==0  && nz > 0 && na==1
                alg = model(input{:});
                obj.setAlgebraicEquation(alg);
                
            elseif nx==0  && nz > 0 && na >= 2
                [alg, y] = model(input{:});
                obj.setAlgebraicEquation(alg);
                obj.setSignal(y);
                
            elseif nx > 0 && nz==0  && na==1
                ode = model(input{:});
                obj.setDifferentialEquation(ode);
                
            elseif nx > 0 && nz==0  && na >= 2
                [ode, y] = model(input{:});
                obj.setDifferentialEquation(ode);
                obj.setSignal(y);
                
            elseif nx > 0 && nz > 0 && na==2
                [ode, alg] = model(input{:});
                obj.setDifferentialEquation(ode);
                obj.setAlgebraicEquation(alg);
                
            elseif nx > 0 && nz > 0 && na >= 3
                [ode, alg, y] = model(input{:});
                obj.setDifferentialEquation(ode);
                obj.setAlgebraicEquation(alg);
                obj.setSignal(y);
            end
            
        end
        
        function input = getModelInput(obj)
            inputVariables = {...
                obj.getIndependent, ...
                obj.getState, ...
                obj.getAlgebraic, ...
                obj.getControl, ...
                obj.getExternalInput, ...
                obj.getParameter, ...
                };
            input = inputVariables(~cellfun('isempty',inputVariables));     
        end
        
        function addDynamicProperties(obj)
            
            yopCustomPropertyNames; 
            obj.addprop(userIndependentVariableProperty);            
            obj.addprop(userStateProperty);            
            obj.addprop(userAlgebraicVariableProperty);            
            obj.addprop(userControlProperty);            
            obj.addprop(userExternalInputProperty);  
            obj.addprop(userParameterProperty);                      
            obj.addprop(userOrdinaryDifferentialEquationProperty);            
            obj.addprop(userAlgebraicEquationProperty);            
            obj.addprop(userSignalOutputProperty);
            
        end
         
        function set(obj, varargin)
            
            ip = inputParser;
            ip.FunctionName = 'set';
            ip.PartialMatching = false;
            ip.KeepUnmatched = true;
            ip.CaseSensitive = true;
            
            yopCustomPropertyNames;
            
            ip.addParameter(userOrdinaryDifferentialEquationProperty, YopIgnore);
            ip.addParameter(userAlgebraicEquationProperty, YopIgnore);
            ip.addParameter(userSignalOutputProperty, YopIgnore);
            
            ip.parse(varargin{:});
            
            if ~isaYopIgnore(ip.Results.(userOrdinaryDifferentialEquationProperty))
                obj.setDifferentialEquation(ip.Results.(userOrdinaryDifferentialEquationProperty));
            end
            if ~isaYopIgnore(ip.Results.(userAlgebraicEquationProperty))
                obj.setAlgebraicEquation(ip.Results.(userAlgebraicEquationProperty));
            end
            if ~isaYopIgnore(ip.Results.(userSignalOutputProperty))
                obj.setSignal(ip.Results.(userSignalOutputProperty));
            end
            
        end
        
        function [value, success] = get(obj, property)
            
            value = [];
            success = false;
            
            yopCustomPropertyNames;
            
            if strcmp(property, userOrdinaryDifferentialEquationProperty)
                value = obj.getSymbolicExpressions.getDifferentialEquation;
                success = true;
                
            elseif strcmp(property, userAlgebraicEquationProperty)
                value = obj.getSymbolicExpressions.getAlgebraicEquation;
                success = true;
                
            elseif strcmp(property, userSignalOutputProperty)
                value = obj.getSymbolicExpressions.getSignals;
                success = true;
                
            elseif strcmp(property, userIndependentVariableProperty)
                value = YopIndependentVariable.getIndependentVariable;
                success = true;
                
            elseif strcmp(property, userStateProperty)
                value = obj.getState;
                success = true;
                
            elseif strcmp(property, userAlgebraicVariableProperty)
                value = obj.getAlgebraic;
                success = true;
                
            elseif strcmp(property, userControlProperty)
                value = obj.getControl;
                success = true;
                
            elseif strcmp(property, userParameterProperty)
                value = obj.getParameter;
                success = true;
                
            elseif strcmp(property, userExternalInputProperty)
                value = obj.getExternalInput;
                success = true;
                
            elseif ~success
                [value, success] = obj.getConstraints.get(property);
                
            end
                
            
        end
        
        
        function nx = numberOfStates(obj)
            nx = length(obj.getState);
        end
        
        function nz = numberOfAlgebraics(obj)
            nz = length(obj.getAlgebraic);
        end
        
        function nu = numberOfControls(obj)
            nu = length(obj.getControl);
        end
        
        function np = numberOfParameters(obj)
            np = length(obj.getParameter);
        end
        
        function ne = numberOfExternalInputs(obj)
            ne = length(obj.getExternalInput);
        end        
        
    end
    
    methods % To be developed
        % [A, B] = linearize(obj, t0, x0, z0, u0, p0);
    end
end







