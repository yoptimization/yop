classdef YopOperatorOverloading < handle
    methods
        
        function y = integral(x)
            y = YopIntegral(@integrate, x);
        end
        
        function y = integrate(x)
            y = integral(x);
        end
        
        function z = plus(x, y)
            z = YopVar.twoArgOperation(x, y, @plus);
        end
        
        function z = minus(x, y)
            z = YopVar.twoArgOperation(x, y, @minus);
        end
        
        function y = uplus(x)
            y = copy(x);
            y.Value = uplus(x.Value);
        end
        
        function y = uminus(x)
            y = copy(x);
            y.Value = uminus(x.Value);
        end
        
        function z = times(x, y)
            z = YopVarGraph(@times, x, y);
        end
        
        function z = mtimes(x, y)
            z = YopVarGraph(@mtimes, x, y);
        end
        
        function z = rdivide(x, y)
            z = YopVarGraph(@rdivide, x, y);
        end
        
        function z = ldivide(x, y)
            z = YopVarGraph(@ldivide, x, y);
        end
        
        function z = mrdivide(x, y)
            z = YopVarGraph(@mrdivide, x, y);
        end
        
        function z = mldivide(x, y)
            z = YopVarGraph(@mldivide, x, y);
        end
        
        function z = power(x, y)
            z = YopVarGraph(@power, x, y);
        end
        
        function z = mpower(x, y)
            z = YopVarGraph(@mpower, x, y);
        end
        
        function y = exp(x)
            z = YopVarGraph(@exp, x);
        end
        
        function y = sign(x)
            y = YopVarGraph(@sign, x);
        end
        
        function y = ctranspose(x)
            y = YopVarGraph(@ctranspose, x);
        end
        
        function y = transpose(x)
            y = YopVarGraph(@transpose, x);
        end
        
        function r = lt(lhs, rhs)
            r = YopVarGraph(@lt, lhs, rhs);
        end
        
        function r = gt(lhs, rhs)
            r = YopVarGraph(@gt, lhs, rhs);
        end
        
        function r = le(lhs, rhs)
            r = YopVarGraph(@le, lhs, rhs);
        end
        
        function r = ge(lhs, rhs)
            r = YopVarGraph(@ge, lhs, rhs);
        end
        
        function r = ne(lhs, rhs)
            r = YopVarGraph(@ne, lhs, rhs);
        end
        
        function r = eq(lhs, rhs)
            r = YopVarGraph(@eq, lhs, rhs);
        end
        
        function b = and(lhs, rhs)
            b = YopVarGraph(@and, lhs, rhs);
        end
        
        function b = or(lhs, rhs)
            b = YopVarGraph(@or, lhs, rhs);
        end
        
        function b = not(lhs, rhs)
            b = YopVarGraph(@not, lhs, rhs);
        end
        
        function s = sum(x)
            s = YopVarGraph(@sum, x);
        end
    end
end