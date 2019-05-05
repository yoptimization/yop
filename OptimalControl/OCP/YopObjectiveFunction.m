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
classdef YopObjectiveFunction < handle
    properties
        Objective
        Mayer = 0
        Lagrange = 0      
        Weight = 1;
    end
    methods
        function obj = YopObjectiveFunction(objective, expression)
            % {t_f(elem) '+' integral(elem)}
            obj.Objective = objective;
            obj.parseExpression(expression)
        end
        
        function parseExpression(obj, expression)
            for k=1:2:length(expression)
                element = expression{k};
                if isa(element, 'YopIntegral')
                    obj.Lagrange = element.Expression;
                    
                elseif isa(element, 'YopFinalTimepoint')
                    obj.Mayer = element.Expression;
                    
                else
                    assert(false, 'Objective function term not recognized');
                end
            end
        end         
        
        function mayer = getMayer(obj)
            if strcmp(obj.Objective, 'min')
                mayer = obj.Mayer;
                
            elseif strcmp(obj.Objective, 'max')
                mayer = -obj.Mayer;
                
            else
                assert(false);
                
            end
        end
        
        function lagrange = getLagrange(obj)
            if strcmp(obj.Objective, 'min')
                lagrange = obj.Lagrange;
                
            elseif strcmp(obj.Objective, 'max')
                lagrange = -obj.Lagrange;
                
            else
                assert(false);
                
            end
        end
        
    end
    
end