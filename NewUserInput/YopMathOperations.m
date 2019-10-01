classdef YopMathOperations < handle
    methods
        function y = yopIntegral(x, varargin)
            y = YopComputationalGraph(@Yop.integrate, x, varargin{:});
        end
        
        function y = yopIntegrate(x, varargin)
            y = yopIntegral(x, varargin{:});
        end
        
        function y = derivative(x, varargin)
            y = YopComputationalGraph(@derivative, x, varargin{:});
        end
        
        function y = differentiate(x, varargin)
            y = derivative(x, varargin{:});
        end
        
        function z = plus(x, y)
            z = YopComputationalGraph(@plus, x, y);
        end
        
        function z = minus(x, y)
            z = YopComputationalGraph(@minus, x, y);
        end
        
        function y = uplus(x)
            y = YopComputationalGraph(@uplus, x);
        end
        
        function y = uminus(x)
            y = YopComputationalGraph(@uminus, x);
        end
        
        function z = times(x, y)
            z = YopComputationalGraph(@times, x, y);
        end
        
        function z = mtimes(x, y)
            z = YopComputationalGraph(@mtimes, x, y);
        end
        
        function z = rdivide(x, y)
            z = YopComputationalGraph(@rdivide, x, y);
        end
        
        function z = ldivide(x, y)
            z = YopComputationalGraph(@ldivide, x, y);
        end
        
        function z = mrdivide(x, y)
            z = YopComputationalGraph(@mrdivide, x, y);
        end
        
        function z = mldivide(x, y)
            z = YopComputationalGraph(@mldivide, x, y);
        end
        
        function z = power(x, y)
            z = YopComputationalGraph(@power, x, y);
        end
        
        function z = mpower(x, y)
            z = YopComputationalGraph(@mpower, x, y);
        end
        
        function y = exp(x)
            z = YopComputationalGraph(@exp, x);
        end
        
        function y = sign(x)
            y = YopComputationalGraph(@sign, x);
        end
        
        function y = ctranspose(x)
            y = YopComputationalGraph(@ctranspose, x);
        end
        
        function y = transpose(x)
            y = YopComputationalGraph(@transpose, x);
        end
        
        function r = lt(lhs, rhs)
            r = YopComputationalGraph(@lt, lhs, rhs);
        end
        
        function r = gt(lhs, rhs)
            r = YopComputationalGraph(@gt, lhs, rhs);
        end
        
        function r = le(lhs, rhs)
            r = YopComputationalGraph(@le, lhs, rhs);
        end
        
        function r = ge(lhs, rhs)
            r = YopComputationalGraph(@ge, lhs, rhs);
        end
        
        function r = ne(lhs, rhs)
            r = YopComputationalGraph(@ne, lhs, rhs);
        end
        
        function r = eq(lhs, rhs)
            r = YopComputationalGraph(@eq, lhs, rhs);
        end
        
        function b = and(lhs, rhs)
            b = YopComputationalGraph(@and, lhs, rhs);
        end
        
        function b = or(lhs, rhs)
            b = YopComputationalGraph(@or, lhs, rhs);
        end
        
        function b = not(lhs, rhs)
            b = YopComputationalGraph(@not, lhs, rhs);
        end
        
        function s = sum(x)
            s = YopComputationalGraph(@sum, x);
        end
    end
end