classdef YopExpression < handle
    
    properties
        Expression
    end
    
    methods
        
        function obj = YopExpression(expression)
            obj.Expression = expression;
        end
        
        function sum = plus(x, y)
            sum = YopExpression.genericOperation(x, y, @plus);
        end
        
        function sum = minus(x, y)
            sum = YopExpression.genericOperation(x, y, @minus);
        end
        
        function product = times(x, y)
            product = YopExpression.genericOperation(x, y, @times);
        end
        
        function ratio = rdivide(x, y)
            ratio = YopExpression.genericOperation(x, y, @rdivide);
        end
        
        function ratio = ldivide(x, y)
            ratio = YopExpression.genericOperation(x, y, @ldivide);
        end
        
        function y = abs(x)
            y = YopExpression( abs(x.value) );
        end
        
        function y = sqrt(x)
            y = YopExpression( sqrt(x.value) );
        end
        
        function y = sin(x)
            y = YopExpression( sin(x.value) );
        end
        
        function y = cos(x)
            y = YopExpression( cos(x.value) );
        end
        
        function y = tan(x)
            y = YopExpression( tan(x.value) );
        end
        
        function y = atan(x)
            y = YopExpression( atan(x.value) );
        end
        
        function y = asin(x)
            y = YopExpression( asin(x.value) );
        end
        
        function y = acos(x)
            y = YopExpression( acos(x.value) );
        end
        
        function y = tanh(x)
            y = YopExpression( tanh(x.value) );
        end
        
        function y = sinh(x)
            y = YopExpression( sinh(x.value) );
        end
        
        function y = cosh(x)
            y = YopExpression( cosh(x.value) );
        end
        
        function y = atanh(x)
            y = YopExpression( sin(x.value) );
        end
        
        function y = asinh(x)
            y = YopExpression( asinh(x.value) );
        end
        
        function y = acosh(x)
            y = YopExpression( acosh(x.value) );
        end
        
        function y = exp(x)
            y = YopExpression( exp(x.value) );
        end
        
        function y = log(x)
            y = YopExpression( log(x.value) );
        end
        
        function y = log10(x)
            y = YopExpression( log10(x.value) );
        end
        
        function y = floor(x)
            y = YopExpression( floor(x.value) );
        end
        
        function y = ceil(x)
            y = YopExpression( ceil(x.value) );
        end
        
        function y = erf(x)
            y = YopExpression(erf(x.value) );
        end
        
        function y = erfinv(x)
            y = YopExpression( erfinv(x.value) );
        end
        
        function y = sign(x)
            y = YopExpression( sign(x.value) );
        end
        
        function y = power(x, p)
            y = YopExpression.genericOperation(x, p, @power);
        end
        
        function y = mod(x, m)
            y = YopExpression.genericOperation(x, m, @mod);
        end
        
        function result = atan2(x, y)
            result = YopExpression.genericOperation(x, y, @atan2);
        end
        
        function result = fmin(x, y)
            result = YopExpression.genericOperation(x, y, @fmin);
        end
        
        function result = fmax(x, y)
            result = YopExpression.genericOperation(x, y, @fmax);
        end
        
        function y = simplify(x)
            y = YopExpression( simplify(x.value) );
        end
        
        function result = is_equal(x, y)
            result = YopExpression.genericOperation(x, y, @is_equal);
        end
        
        function result = copysign(x, y)
            result = YopExpression.genericOperation(x, y, @copysign);
        end
        
        function result = constpow(x, y)
            result = YopExpression.genericOperation(x, y, @constpow);
        end
        
        function y = uplus(x)
            y = YopExpression( uplus(x.value) );
        end 
        
        function y = uminus(x)
            y = YopExpression( uminus(x.value) );
        end      
               
        function y = T(x)
            y = YopExpression( T(x.value) );
        end
        
        function y = transpose(x)
            y = YopExpression( transpose(x.value) );
        end
        
        function y = ctranspose(x)
            y = YopExpression( ctranspose(x.value) );
        end
        
        function product = mtimes(x, y)
            product = YopExpression.genericOperation(x, y, @mtimes);
        end
        
        function ratio = mldivide(x, y)
            ratio = YopExpression.genericOperation(x, y, @mldivide);
        end
        
        function ratio = mrdivide(x, y)
            ratio = YopExpression.genericOperation(x, y, @mrdivide);
        end
        
        function y = mpower(x, p)
            y = YopExpression.genericOperation(x, p, @mpower);
        end
        

        function x = horzcat(varargin)
            vector = [];
            for k=1:length(varargin)
                elem = varargin{k};
                vector = horzcat(vector, elem.value);
            end
            x = YopExpression( vector );
        end
        
        function x = vertcat(varargin)
            vector = [];
            for k=1:length(varargin)
                elem = varargin{k};
                vector = vertcat(vector, elem.value);
            end
            x = YopExpression( vector );
        end
        
        function x = subsasgn(x, s, y)
            if strcmp(s.type, '()')
                elem = x.value;
                elem(s.subs{:}) = y;
                
            elseif strcmp(s.type, '{}')
                elem = x.value;
                elem{s.subs{:}} = y;
                
            elseif strcmp(s.type, '.')
                x.(s.subs) = y;
                
            end
        end
        
        function s = subsref(obj, a)
            % x(t_0) special case
            
            if strcmp(a.type, '()')
                v = obj.value;
                s = YopExpression( v(a.subs{:}) );
                
            elseif strcmp(a.type, '{}')
                v = obj.value;
                s = YopExpression( v{a.subs{:}} );
                
            elseif strcmp(a.type, '.')
                s = obj.(a.subs);
                
            end
                
        end
        
        
        %         function size
        %         end
        %
        %         function length
        %         end
        
        
        function relation = le(x, y)
            relation = YopRelation(x, y, @le);
        end
    
        function v = value(obj)
            v = obj.Expression;
        end
        
    end
    
    methods (Static)
        
        function result = genericOperation(obj1, obj2, operation)
            result = YopExpression( operation(YopExpression.eval(obj1), YopExpression.eval(obj2)) );
        end
        
        function expression = eval(obj)
            if isa(obj, 'YopExpression')
                expression = obj.Expression;
            else
                expression = obj;
            end
        end
        
        function obj = Variable(symbol, rows, columns)
            if nargin == 0
                variable = casadi.MX.sym('x');
                
            elseif nargin == 1
                variable = casadi.MX.sym(symbol);
                
            elseif nargin == 2
                variable = casadi.MX.sym(symbol, rows);
                
            elseif nargin == 3
                variable = casadi.MX.sym(symbol, rows, columns);
                
            end
            obj = YopExpression(variable);
        end   
        
    end
end