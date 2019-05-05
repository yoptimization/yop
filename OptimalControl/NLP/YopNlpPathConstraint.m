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
classdef YopNlpPathConstraint < handle
    properties
        Vector
        UpperBound
        LowerBound
        
        Dynamics
        Initial
        Final
        Path
        StrictPath
        
        Counter
    end
    methods
        
        function obj = YopNlpPathConstraint
            obj.Vector = [];
            obj.UpperBound = [];
            obj.LowerBound = [];
            obj.Counter = 1;
        end
        
        function index = add(obj, expression)
            obj.Vector = vertcat(obj.Vector, expression);
            
            index = obj.Counter:(obj.Counter + length(expression) - 1);
            
            obj.Counter = obj.Counter + length(expression);
        end        
        
        function dynamics(obj, expression)
            index = obj.add(expression);
            obj.Dynamics = [obj.Dynamics, index];            
        end
        
        function initial(obj, expression)
            index = obj.add(expression);
            obj.Initial = [obj.Initial, index];
        end
        
        function final(obj, expression)
            index = obj.add(expression);
            obj.Final = [obj.Final, index];
        end
        
        function path(obj, expression)
            index = obj.add(expression);
            obj.Path = [obj.Path, index];
        end
        
        function strictPath(obj, expression)
            index = obj.add(expression);
            obj.StrictPath = [obj.StrictPath, index];
        end
        
    end
end