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
classdef YopNonlinearConstraint < YopConstraint
    properties
        Input  
        Descaling
    end
    methods
        function obj = YopNonlinearConstraint(constraint, expression, upper, lower, input, descaling)
            obj@YopConstraint(constraint, expression, upper, lower);
            obj.Input = input;
            obj.Descaling = descaling;
        end
        
        function g = evaluate(obj, input, descaling, ts, xs, zs, us, ps)            
            g = [];
            if ~isempty(obj)
                f = casadi.Function('g', input, {obj.getExpression});
                
                [t, x, z, u, p] = descaling(ts, xs, zs, us, ps);
                g = f(t, x, z, u, p);
            end
            
        end
    end
    
end