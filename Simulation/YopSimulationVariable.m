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
classdef YopSimulationVariable < handle
    properties
        Variable
        InitialValue
    end
    methods
        function obj = YopSimulationVariable(variable)
            obj.Variable = variable;
        end
        function val = depends_on(obj, variable)
            try
                val = depends_on(obj.Variable, variable);
            catch
                val = false;
            end
        end
    end    
    methods (Static)
        function obj = initializeArray(variables)
            arr = YopArray;
            for k=1:length(variables)
                arr.store( YopSimulationVariable(variables(k)) );
            end
            obj = arr.getElements;
            
            if isempty(variables)
                obj = YopSimulationVariable([]);
            end
        end
    end
end