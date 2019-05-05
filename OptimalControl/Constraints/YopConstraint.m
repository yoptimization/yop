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
classdef YopConstraint < handle
    properties
        Constraint
        Expression
        Upper
        Lower
        Components
    end
    methods
        function obj = YopConstraint(constraint, expression, upperBound, lowerBound)
            obj.Constraint = constraint;
            obj.Expression = expression;
            
            ub(length(expression), 1) = YopBound;
            obj.Upper = ub;
            obj.Upper.set(upperBound);
            
            lb(length(expression), 1) = YopBound;
            obj.Lower = lb;
            obj.Lower.set(lowerBound);
            
            components = [];
            for k=1:length(expression)
                components = [components; YopConstraintComponent(...
                    obj, expression(k), obj.Upper(k), obj.Lower(k))];
            end
            obj.Components = components;
        end
        
        function expression = getExpression(obj)
            expression = vertcat(obj.Expression);
        end
        
        function components = getComponents(obj)
            components = vertcat(obj.Components);
        end
        
        function setUpper(obj, upper)
            ub = vertcat(obj.Upper);
            ub.set(upper);
        end
        
        function setLower(obj, lower)
            lb = vertcat(obj.Lower);
            lb.set(lower);
        end
        
        function upper = getUpper(obj)
            ub = vertcat(obj.Upper);
            upper = ub.get;
        end
        
        function lower = getLower(obj)
            lb = vertcat(obj.Lower);
            lower = lb.get;
        end
    end
end