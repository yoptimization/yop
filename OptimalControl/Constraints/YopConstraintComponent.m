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
classdef YopConstraintComponent < handle
    properties
        Parent
        Expression
        Upper
        Lower
    end
    methods
        function obj = YopConstraintComponent(parent, expression, upper, lower)
            obj.Parent = parent;
            obj.Expression = expression;
            obj.Upper = upper;
            obj.Lower = lower;
        end
                
        function val = dependsOn(obj, variable)
           val = is_equal(obj.Expression, variable);
        end
       
        function setUpper(obj, bound)
            obj.Upper.set(bound);
        end
        
        function setLower(obj, bound)
            obj.Lower.set(bound);
        end
        
    end
end