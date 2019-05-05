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
classdef YopConstraintPattern < handle
    properties
        Pattern
        ExpressionGetter
        UpperBoundGetter
        LowerBoundGetter
        TimepointGetter
    end
    methods
        function obj = YopConstraintPattern(pattern, expressionGetter, upperGetter, lowerGetter)
            obj.Pattern = pattern;
            obj.ExpressionGetter = expressionGetter;
            obj.UpperBoundGetter = upperGetter;
            obj.LowerBoundGetter = lowerGetter;
            
        end
        
        function value = match(obj, constraint)
            try 
                match = zeros(size(obj.Pattern));
                for k=1:length(constraint)
                    match(k) = YopConstraintPattern.compare(obj.Pattern{k}, constraint{k});
                end
                value = sum(match) == length(obj.Pattern);                
                
            catch
                value = false;
            end
        end
        
        function [expression, upperBound, lowerBound] = parse(obj, constraint)
            expression = obj.ExpressionGetter(constraint);
            upperBound = obj.UpperBoundGetter(constraint);
            lowerBound = obj.LowerBoundGetter(constraint);
        end
        
    end
    
    methods (Static)
        
        function val = compare(patternEntry, constraintEntry)
            try
                if strcmp(patternEntry, '==') || strcmp(patternEntry, '<=') || strcmp(patternEntry, '>=')
                    val = strcmp(patternEntry, constraintEntry);
                    
                elseif strcmp(patternEntry, 'numeric')
                    val = isnumeric(constraintEntry);
                    
                elseif strcmp(patternEntry, 'x')
                    val = isa(constraintEntry, 'casadi.MX') && yopIsValidInput(constraintEntry);
                    
                elseif strcmp(patternEntry, 'f(x)')
                    val = isa(constraintEntry, 'casadi.MX') && ~yopIsValidInput(constraintEntry);                                        
                    
                elseif strcmp(patternEntry, 'BoxInitialTimepoint')
                    val = isa(constraintEntry, 'YopInitialTimepoint') && isValidInput(constraintEntry);
                    
                elseif strcmp(patternEntry, 'BoxFinalTimepoint')
                    val = isa(constraintEntry, 'YopFinalTimepoint') && isValidInput(constraintEntry);
                    
                elseif strcmp(patternEntry, 'BoxTimepoint')
                    val = (isa(constraintEntry, 'YopInitialTimepoint') || isa(constraintEntry, 'YopFinalTimepoint') ) && isValidInput(constraintEntry);
                
                elseif strcmp(patternEntry, 'InitialBoundary') 
                    val = isa(constraintEntry, 'YopInitialTimepoint') && ~isValidInput(constraintEntry);
                    
                elseif strcmp(patternEntry, 'FinalBoundary') 
                    val = isa(constraintEntry, 'YopFinalTimepoint') && ~isValidInput(constraintEntry);    
                    
                elseif strcmp(patternEntry, 'PathTimepoint') 
                    val = isa(constraintEntry, 'YopTimepointExpression') && ~isValidInput(constraintEntry);
                    
                end
                
            catch
                val = false;
                
            end    
        end
    end
end