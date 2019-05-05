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
classdef YopScaling < handle
    properties
        Variable
        Weight
        Offset
    end
    methods
        function obj = YopScaling
        end
        
        function setVariable(obj, variable)
            for k=1:length(obj)
                obj(k).Variable = variable(k);
            end
        end
        
        function setWeight(obj, weight)
            for k=1:length(obj)
                obj(k).Weight = weight(k);
            end
        end
        
        function setOffset(obj, offset)
            for k=1:length(obj)
                obj(k).Offset = offset(k);
            end
        end
        
        function val = mapsTo(obj, variable)
           val = is_equal(obj.Variable, variable);
        end
    end   
end