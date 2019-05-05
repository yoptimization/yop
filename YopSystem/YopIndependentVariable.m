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
classdef YopIndependentVariable < handle
    
    properties
        IndependentVariable
    end
    
    methods (Access = private)
        function obj = YopIndependentVariable()
            import casadi.*
            yopCustomPropertyNames;
            obj.IndependentVariable = MX.sym(userIndependentVariableProperty);
        end
    end
    
    methods (Static)
        function var = getIndependentVariable()
            persistent singleton
            if isempty(singleton)
                obj = YopIndependentVariable();
                singleton = obj;
            else
                obj = singleton;
            end
            var = obj.IndependentVariable;
        end
    end
    
end