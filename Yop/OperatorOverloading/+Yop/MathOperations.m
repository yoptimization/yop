classdef MathOperations < handle
    methods
        function y = yopIntegral(x, varargin)
            y = Yop.ComputationalGraph(@Yop.integrate, x, varargin{:});
        end
        
        function y = yopIntegrate(x, varargin)
            y = yopIntegral(x, varargin{:});
        end
        
        function y = derivative(x, varargin)
            y = Yop.ComputationalGraph(@derivative, x, varargin{:});
        end
        
        function y = differentiate(x, varargin)
            y = derivative(x, varargin{:});
        end
        
        function z = plus(x, y)
            z = Yop.ComputationalGraph(@plus, x, y);
        end
        
        function z = minus(x, y)
            z = Yop.ComputationalGraph(@minus, x, y);
        end
        
        function y = uplus(x)
            y = Yop.ComputationalGraph(@uplus, x);
        end
        
        function y = uminus(x)
            y = Yop.ComputationalGraph(@uminus, x);
        end
        
        function z = times(x, y)
            z = Yop.ComputationalGraph(@times, x, y);
        end
        
        function z = mtimes(x, y)
            z = Yop.ComputationalGraph(@mtimes, x, y);
        end
        
        function z = rdivide(x, y)
            z = Yop.ComputationalGraph(@rdivide, x, y);
        end
        
        function z = ldivide(x, y)
            z = Yop.ComputationalGraph(@ldivide, x, y);
        end
        
        function z = mrdivide(x, y)
            z = Yop.ComputationalGraph(@mrdivide, x, y);
        end
        
        function z = mldivide(x, y)
            z = Yop.ComputationalGraph(@mldivide, x, y);
        end
        
        function z = power(x, y)
            z = Yop.ComputationalGraph(@power, x, y);
        end
        
        function z = mpower(x, y)
            z = Yop.ComputationalGraph(@mpower, x, y);
        end
        
        function y = exp(x)
            z = Yop.ComputationalGraph(@exp, x);
        end
        
        function y = sign(x)
            y = Yop.ComputationalGraph(@sign, x);
        end
        
        function y = ctranspose(x)
            y = Yop.ComputationalGraph(@ctranspose, x);
        end
        
        function y = transpose(x)
            y = Yop.ComputationalGraph(@transpose, x);
        end
        
        function r = lt(lhs, rhs)
            r = Yop.ComputationalGraph(@lt, lhs, rhs);
        end
        
        function r = gt(lhs, rhs)
            r = Yop.ComputationalGraph(@gt, lhs, rhs);
        end
        
        function r = le(lhs, rhs)
            r = Yop.ComputationalGraph(@le, lhs, rhs);
        end
        
        function r = ge(lhs, rhs)
            r = Yop.ComputationalGraph(@ge, lhs, rhs);
        end
        
        function r = ne(lhs, rhs)
            r = Yop.ComputationalGraph(@ne, lhs, rhs);
        end
        
        function r = eq(lhs, rhs)
            r = Yop.ComputationalGraph(@eq, lhs, rhs);
        end
        
        function b = and(lhs, rhs)
            b = Yop.ComputationalGraph(@and, lhs, rhs);
        end
        
        function b = or(lhs, rhs)
            b = Yop.ComputationalGraph(@or, lhs, rhs);
        end
        
        function b = not(lhs, rhs)
            b = Yop.ComputationalGraph(@not, lhs, rhs);
        end
        
        function s = sum(x)
            s = Yop.ComputationalGraph(@sum, x);
        end
    end
end