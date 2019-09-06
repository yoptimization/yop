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
classdef YopIntegral < YopExpression
    methods
        function obj = YopIntegral(expression)
            obj@YopExpression(expression);
        end
        
        function sum = plus(x, y)
        end
        
        function sum = minus(x, y)
        end
        
        function y = abs(x)
        end
        
        function y = sqrt(x)
        end
        
        function y = sin(x)
        end
        
        function y = cos(x)
        end
        
        function y = tan(x)
        end
        
        function y = atan(x)
        end
        
        function y = asin(x)
        end
        
        function y = acos(x)
        end
        
        function y = tanh(x)
        end
        
        function y = sinh(x)
        end
        
        function y = cosh(x)
        end
        
        function y = atanh(x)
        end
        
        function y = asinh(x)
        end
        
        function y = acosh(x)
        end
        
        function y = exp(x)
        end
        
        function y = log(x)
        end
        
        function y = log10(x)
        end
        
        function y = floor(x)
        end
        
        function y = ceil(x)
        end
        
        function y = erf(x)
        end
        
        function y = erfinv(x)
        end
        
        function y = sign(x)
        end
        
        function y = power(x, p)
        end
        
        function y = mod(x, m)
        end
        
        function result = atan2(x, y)
        end
        
    end
end