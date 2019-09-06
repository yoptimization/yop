classdef YopExpression2 < handle
    
    properties
        Expression
        Timepoint
    end
    
    methods
        
        function obj = YopExpression2(expression)
            obj.Expression = expression;
            obj.Timepoint = YopIndependentVariable.getIndependentVariable;
        end
        
        function sum = plus(x, y)
            sum = YopExpression2.genericOperation(x, y, @plus);
        end
        
        function sum = minus(x, y)
            sum = YopExpression2.genericOperation(x, y, @minus);
        end
        
        function product = times(x, y)
            product = YopExpression2.genericOperation(x, y, @times);
        end
        
        function ratio = rdivide(x, y)
            ratio = YopExpression2.genericOperation(x, y, @rdivide);
        end
        
        function ratio = ldivide(x, y)
            ratio = YopExpression2.genericOperation(x, y, @ldivide);
        end
        
        function relation = lt(lhs, rhs)
            lhs = YopExpression2.convert(lhs);
            rhs = YopExpression2.convert(rhs);
            relation = YopRelation(lhs, rhs, @lt);
        end       
        
        function relation = le(lhs, rhs)
            lhs = YopExpression2.convert(lhs);
            rhs = YopExpression2.convert(rhs);
            relation = YopRelation(lhs, rhs, @le);
        end
        
        function relation = gt(lhs, rhs)
            lhs = YopExpression2.convert(lhs);
            rhs = YopExpression2.convert(rhs);
            relation = YopRelation(lhs, rhs, @gt);
        end
        
        function relation = ge(lhs, rhs)
            lhs = YopExpression2.convert(lhs);
            rhs = YopExpression2.convert(rhs);
            relation = YopRelation(lhs, rhs, @ge);
        end
        
        function relation = eq(lhs, rhs)
            lhs = YopExpression2.convert(lhs);
            rhs = YopExpression2.convert(rhs);
            relation = YopRelation(lhs, rhs, @eq);
        end
        
        function relation = ne(lhs, rhs)
            lhs = YopExpression2.convert(lhs);
            rhs = YopExpression2.convert(rhs);
            relation = YopRelation(lhs, rhs, @ne);
        end
        
        function relation = and(lhs, rhs)
            lhs = YopExpression2.convert(lhs);
            rhs = YopExpression2.convert(rhs);
            relation = YopRelation(lhs, rhs, @and);
        end
        
        function relation = or(lhs, rhs)
            lhs = YopExpression2.convert(lhs);
            rhs = YopExpression2.convert(rhs);
            relation = YopRelation(lhs, rhs, @or);
        end
        
        function relation = not(lhs, rhs)
            lhs = YopExpression2.convert(lhs);
            rhs = YopExpression2.convert(rhs);
            relation = YopRelation(lhs, rhs, @not);
        end
        
        function y = abs(x)
            y = YopExpression2( abs(x.value) );
        end
        
        function y = sqrt(x)
            y = YopExpression2( sqrt(x.value) );
        end
        
        function y = sin(x)
            y = YopExpression2( sin(x.value) );
        end
        
        function y = cos(x)
            y = YopExpression2( cos(x.value) );
        end
        
        function y = tan(x)
            y = YopExpression2( tan(x.value) );
        end
        
        function y = atan(x)
            y = YopExpression2( atan(x.value) );
        end
        
        function y = asin(x)
            y = YopExpression2( asin(x.value) );
        end
        
        function y = acos(x)
            y = YopExpression2( acos(x.value) );
        end
        
        function y = tanh(x)
            y = YopExpression2( tanh(x.value) );
        end
        
        function y = sinh(x)
            y = YopExpression2( sinh(x.value) );
        end
        
        function y = cosh(x)
            y = YopExpression2( cosh(x.value) );
        end
        
        function y = atanh(x)
            y = YopExpression2( sin(x.value) );
        end
        
        function y = asinh(x)
            y = YopExpression2( asinh(x.value) );
        end
        
        function y = acosh(x)
            y = YopExpression2( acosh(x.value) );
        end
        
        function y = exp(x)
            y = YopExpression2( exp(x.value) );
        end
        
        function y = log(x)
            y = YopExpression2( log(x.value) );
        end
        
        function y = log10(x)
            y = YopExpression2( log10(x.value) );
        end
        
        function y = floor(x)
            y = YopExpression2( floor(x.value) );
        end
        
        function y = ceil(x)
            y = YopExpression2( ceil(x.value) );
        end
        
        function y = erf(x)
            y = YopExpression2(erf(x.value) );
        end
        
        function y = erfinv(x)
            y = YopExpression2( erfinv(x.value) );
        end
        
        function y = sign(x)
            y = YopExpression2( sign(x.value) );
        end
        
        function y = power(x, p)
            y = YopExpression2.genericOperation(x, p, @power);
        end
        
        function y = mod(x, m)
            y = YopExpression2.genericOperation(x, m, @mod);
        end
        
        function result = atan2(x, y)
            result = YopExpression2.genericOperation(x, y, @atan2);
        end
        
        function result = fmin(x, y)
            result = YopExpression2.genericOperation(x, y, @fmin);
        end
        
        function result = fmax(x, y)
            result = YopExpression2.genericOperation(x, y, @fmax);
        end
        
        function y = simplify(x)
            y = YopExpression2( simplify(x.value) );
        end
        
        function result = is_equal(x, y)
            result = YopExpression2.genericOperation(x, y, @is_equal);
        end
        
        function result = copysign(x, y)
            result = YopExpression2.genericOperation(x, y, @copysign);
        end
        
        function result = constpow(x, y)
            result = YopExpression2.genericOperation(x, y, @constpow);
        end
        
        function y = uplus(x)
            y = YopExpression2( uplus(x.value) );
        end 
        
        function y = uminus(x)
            y = YopExpression2( uminus(x.value) );
        end      
               
        function y = T(x)
            y = YopExpression2( T(x.value) );
        end
        
        function y = transpose(x)
            y = YopExpression2( transpose(x.value) );
        end
        
        function y = ctranspose(x)
            y = YopExpression2( ctranspose(x.value) );
        end
        
        function product = mtimes(x, y)
            product = YopExpression2.genericOperation(x, y, @mtimes);
        end
        
        function ratio = mldivide(x, y)
            ratio = YopExpression2.genericOperation(x, y, @mldivide);
        end
        
        function ratio = mrdivide(x, y)
            ratio = YopExpression2.genericOperation(x, y, @mrdivide);
        end
        
        function y = mpower(x, p)
            y = YopExpression2.genericOperation(x, p, @mpower);
        end
        
        
        function i = integral(obj)
            % Return a YopIntegral object
            i = YopIntegral(obj.Expression);
        end
        
        function i = integrate(obj)
            % Wrap yop integtral.
            % Syntax: integral(expression)
            %         expression.integrate
        end
        

        function x = horzcat(varargin)
            vector = [];
            for k=1:length(varargin)
                elem = varargin{k};
                vector = horzcat(vector, elem.value);
            end
            x = YopExpression2( vector );
        end
        
        function x = vertcat(varargin)
            vector = [];
            for k=1:length(varargin)
                elem = varargin{k};
                vector = vertcat(vector, elem.value);
            end
            x = YopExpression2( vector );
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
            
            if strcmp(a.type, '()') && isa(a.subs{1}, 'YopExpression2')
                e = a.subs{1};
                if isequal(e.Expression, ...
                        YopIndependentVariable.getIndependentFinal)
                    s = YopFinalTimepoint(obj.Expression);
                    
                elseif isequal(e.Expression, ...
                        YopIndependentVariable.getIndependentInitial)
                    s = YopInitialTimepoint(obj.Expression);
                    
                else
                    YopAssert(false, ...
                        'Subsref failed due to unrecognized argument.');
                    
                end
                
            elseif strcmp(a.type, '()')
                v = obj.value;
                s = YopExpression2( v(a.subs{:}) );
                
            elseif strcmp(a.type, '{}')
                v = obj.value;
                s = YopExpression2( v{a.subs{:}} );
                
            elseif strcmp(a.type, '.')
                s = obj.(a.subs);
                
            end
                
        end
        
    
        function v = value(obj)
            v = obj.Expression;
        end
        
        function bool = isValidInput(obj)
            if isa(obj.Expression, 'casadi.MX')
                bool = is_valid_input(obj.Expression);
            else
                bool = false;
            end
        end
        
        function bool = isNumeric(obj)
            bool = isnumeric(obj.Expression);
        end
        
    end
    
    methods (Static)
        
        function x = convert(x)
            if isa(x, 'numeric')
                x = YopExpression2(x);
            end
        end
        
        function result = genericOperation(obj1, obj2, operation)
            if isa(obj1, 'YopExpression2Graph') || ...
                    isa(obj2, 'YopExpression2Graph')
                result = YopExpression2Graph(operation, obj1, obj2);
                
            elseif isa(obj1,  'YopTimepointExpression') && ...
                    isa(obj2,  'YopTimepointExpression') && ...
                    ~isequal(class(obj1), class(obj2))
                result = YopExpression2Graph(operation, obj1, obj2);
                
            elseif  isequal(class(obj1), class(obj2))
                eval(['result = ' class(obj1) ...
                    '( operation(obj1.Expression, obj2.Expression) );']);
                
            elseif isa(obj1, 'YopExpression2')
                eval(['result = ' class(obj1) ...
                    '(operation(obj1.Expression, YopExpression2.eval(obj2)));']);
                
            elseif isa(obj2, 'YopExpression2')
                eval(['result = ' class(obj2) ...
                    '(operation(YopExpression2.eval(obj1),  obj2.Expression));']);
                
            else
                YopAssert(false, 'Unrecognized expression.');
                
            end
        end
        
        function expression = eval(obj)
            if isa(obj, 'YopExpression2')
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
            obj = YopExpression2(variable);
        end   
        
    end
end