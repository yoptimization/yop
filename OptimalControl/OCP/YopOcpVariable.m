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
classdef YopOcpVariable < handle
    properties
        Variable
        Upper
        Lower
        InitialUpper
        InitialLower
        FinalUpper
        FinalLower
        Weight
        Offset
    end
    methods
        
        function obj = YopOcpVariable()
        end
        
        function setVariable(obj, variable)
            obj.Variable = variable;
        end
        
        function setUpper(obj, bound)
            upper = vertcat(obj.Upper);
            upper.set(bound);
        end
        
        function setLower(obj, bound)
            lower = vertcat(obj.Lower);
            lower.set(bound);
        end
        
        function setBound(obj, bound)
            obj.setUpper(bound);
            obj.setLower(bound);
        end
        
        function setInitialUpper(obj, bound)
            upper = vertcat(obj.InitialUpper);
            upper.set(bound);
        end
        
        function setInitialLower(obj, bound)
            lower = vertcat(obj.InitialLower);
            lower.set(bound);
        end
        
        function setInitial(obj, bound)
            obj.setInitialUpper(bound);
            obj.setInitialLower(bound);
        end
        
        function setFinalUpper(obj, bound)
            upper = vertcat(obj.FinalUpper);
            upper.set(bound);
        end
        
        function setFinalLower(obj, bound)
            lower = vertcat(obj.FinalLower);
            lower.set(bound);
        end
        
        function setFinal(obj, bound)
            obj.setFinalUpper(bound);
            obj.setFinalLower(bound);
        end
        
        function setWeight(obj, value)
            for k=1:length(obj)
                obj(k).Weight = value(k);
            end
        end
        
        function setOffset(obj, value)
            for k=1:length(obj)
                obj(k).Offset = value(k);
            end
        end
        
        function variable = getVariable(obj)
            variable = vertcat(obj.Variable);
        end
        
        function bound = getUpper(obj, default)
            bound = nan(length(obj),1);
            for k=1:length(obj)
                if isempty(obj(k).Upper)
                    bound(k) = default;
                else
                    bound(k) = obj(k).Upper.get;
                end
            end  

        end
        
        function bound = getLower(obj, default)
            bound = nan(length(obj),1);
            for k=1:length(obj)
                if isempty(obj(k).Lower)
                    bound(k) = default;
                else
                    bound(k) = obj(k).Lower.get;
                end
            end
        end
        
        function bound = getInitialUpper(obj, default)
            bound = nan(length(obj),1);
            for k=1:length(obj)
                if isempty(obj(k).InitialUpper)
                    bound(k) = obj(k).getUpper(default);
                else
                    bound(k) = obj(k).InitialUpper.get;
                end
            end
        end
        
        function bound = getInitialLower(obj, default)
            bound = nan(length(obj),1);
            for k=1:length(obj)
                if isempty(obj(k).InitialLower)
                    bound(k) = obj(k).getLower(default);
                else
                    bound(k) = obj(k).InitialLower.get;
                end
            end  
        end
        
        function bound = getFinalUpper(obj, default)
            bound = nan(length(obj),1);
            for k=1:length(obj)
                if isempty(obj(k).FinalLower)
                    bound(k) = obj(k).getUpper(default);
                else
                    bound(k) = obj(k).FinalUpper.get;
                end
            end          
        end
        
        function bound = getFinalLower(obj, default)
            bound = nan(length(obj),1);
            for k=1:length(obj)
                if isempty(obj(k).FinalLower)
                    bound(k) = obj(k).getLower(default);
                else
                    bound(k) = obj(k).FinalLower.get;
                end
            end
        end 
        
        function bound = getUpperScaled(obj, default)
            bound = obj.scale( obj.getUpper(default) );
        end
        
        function bound = getLowerScaled(obj, default)
            bound = obj.scale( obj.getLower(default) );
        end
        
        function bound = getInitialUpperScaled(obj, default)
            bound = obj.scale( obj.getInitialUpper(default) );
        end
        
        function bound = getInitialLowerScaled(obj, default)
            bound = obj.scale( obj.getInitialLower(default) );
        end
        
        function bound = getFinalUpperScaled(obj, default)
            bound = obj.scale( obj.getFinalUpper(default) );
        end
        
        function bound = getFinalLowerScaled(obj, default)
            bound = obj.scale( obj.getFinalLower(default) );
        end 
             
        function weight = getWeight(obj)
            weight = nan(length(obj),1);
            for k=1:length(obj)
                if isempty(obj(k).Weight)
                    weight(k) = 1;
                else
                    weight(k) = obj(k).Weight;
                end
            end 
        end
        
        function offset = getOffset(obj)
            offset = nan(length(obj),1);
            for k=1:length(obj)
                if isempty(obj(k).Offset)
                    offset(k) = 0;
                else
                    offset(k) = obj(k).Offset;
                end
            end
        end
        
        function scaledVariable = scale(obj, variable)
            weight = obj.getWeight;
            offset = obj.getOffset;
            scaledVariable = weight.*variable - offset;
        end
        
        function descaledVariable = descale(obj, variable)
            weight = obj.getWeight;
            offset = obj.getOffset;
            descaledVariable = (variable - offset)./weight;
        end
        
    end
    
    methods (Static)
        
        function obj = constructor(variables)
            obj = YopOcpVariable;
            if ~isempty(variables)                
                obj(length(variables), 1) = YopOcpVariable;
                
                for k=1:length(variables)
                    obj(k).setVariable(variables(k));
                    
                end
            end
        end
        
    end
end