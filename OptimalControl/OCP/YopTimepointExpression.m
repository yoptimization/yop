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
classdef YopTimepointExpression < YopTimepoint
    
    properties
        Expression
    end
    
    methods
        function obj = YopTimepointExpression(timepoint, expression)
            obj@YopTimepoint(timepoint);
            obj.Expression = expression;
        end
        
        function l = length(obj)
            l = length(obj.Expression);
        end   
        
        function val = isValidInput(obj)
            val = yopIsValidInput(obj.Expression);
        end
        
        function val = is_equal(obj, expression)
            val = is_equal(obj.Expression, expression);
        end
        
        function sum = plus(obj1, obj2)
            arg1 = YopTimepointExpression.parseForIndependent(obj1);
            arg2 = YopTimepointExpression.parseForIndependent(obj2);
            sum = arg1 + arg2;         
        end
        
        function difference = minus(obj1, obj2)
            arg1 = YopTimepointExpression.parseForIndependent(obj1);
            arg2 = YopTimepointExpression.parseForIndependent(obj2);
            difference = arg1 - arg2;
        end
        
        function term = uplus(obj)
            term = YopTimepointExpression.parseForIndependent(obj);          
        end
        
        function term = uminus(obj)
            term = -YopTimepointExpression.parseForIndependent(obj); 
        end
        
        function product = times(obj1, obj2)
            arg1 = YopTimepointExpression.parseForIndependent(obj1);
            arg2 = YopTimepointExpression.parseForIndependent(obj2);
            product = arg1.*arg2;
        end
        
        function product = mtimes(obj1, obj2)
            arg1 = YopTimepointExpression.parseForIndependent(obj1);
            arg2 = YopTimepointExpression.parseForIndependent(obj2);
            product = arg1*arg2;
        end
        
        function product = rdivide(obj1, obj2)
            arg1 = YopTimepointExpression.parseForIndependent(obj1);
            arg2 = YopTimepointExpression.parseForIndependent(obj2);
            product = arg1./arg2;
        end
        
        function product = ldivide(obj1, obj2)
            arg1 = YopTimepointExpression.parseForIndependent(obj1);
            arg2 = YopTimepointExpression.parseForIndependent(obj2);
            product = arg1.\arg2;
        end
        
        function product = mrdivide(obj1, obj2)
            arg1 = YopTimepointExpression.parseForIndependent(obj1);
            arg2 = YopTimepointExpression.parseForIndependent(obj2);
            product = arg1/arg2;
        end
        
        function product = mldivide(obj1, obj2)
            arg1 = YopTimepointExpression.parseForIndependent(obj1);
            arg2 = YopTimepointExpression.parseForIndependent(obj2);
            product = arg1.\arg2;
        end
        
        function product = power(obj1, obj2)
            arg1 = YopTimepointExpression.parseForIndependent(obj1);
            arg2 = YopTimepointExpression.parseForIndependent(obj2);
            product = arg1.^arg2;
        end
        
        function product = mpower(obj1, obj2)
            arg1 = YopTimepointExpression.parseForIndependent(obj1);
            arg2 = YopTimepointExpression.parseForIndependent(obj2);
            product = arg1^arg2;
        end
    end
    
    methods (Static)
        
        function var = parseForIndependent(obj)
            if isa(obj, 'YopInitialTimepoint')
                var = YopIndependentVariable.getIndependentInitial;
                
            elseif isa(obj, 'YopFinalTimepoint')
                var = YopIndependentVariable.getIndependentFinal;
                
            else
                var = obj;
                
            end
        end
        
    end
    
end