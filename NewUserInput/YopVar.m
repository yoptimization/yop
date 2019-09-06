classdef YopVar < handle & matlab.mixin.Copyable
    
    properties
        Value
    end
    
    methods   
        function obj = YopVar(expression)
            obj.Value = expression;
        end
        
        function v = value(obj)
            v = obj.Value;
        end
        
        function disp(obj)
            disp(obj.Value);
        end
        
        function display(obj)
            eval([inputname(1) '= obj.Value']);
        end
        
        function bool = isIndependentInitial(obj)
            bool = isequal(obj, YopVar.getIndependentInitial);
        end
        
        function bool = isIndependentFinal(obj)
            bool = isequal(obj, YopVar.getIndependentFinal);
        end
        
        function bool = isaVariable(obj)
            try
                bool = is_valid_input(obj.Value);
            catch
                bool = false;
            end
        end
        
        function bool = isnumeric(obj)
            bool = isnumeric(obj.Value);
        end
        
        function val = evaluateAtTimepoint(obj, timepoint, nlpVariables)
            
        end
    end
    
    methods % YopVar/-Graph Interface        
        function bool = areEqual(x, y)
            bool = isequal(class(x), class(y));
        end
        
        function value = evaluate(obj)
            value = obj.Value;
        end
        
        function n = numberOfNodes(obj)
            n = 0;
        end
        
        function o = getOperations(obj)
            o = {};
        end
        
        function n = numberOfInputArguments(obj)
            n = 1;
        end
        
        function i = getInputArguments(obj)
            i = {obj};
        end
        
        function obj = leftmostExpression(obj)
        end
        
        function obj = rightmostExpression(obj)
        end
        
        function bool = isaExpression(obj)
            bool = true;
        end            
        
        function bool = isaRelation(obj)
            bool = false;
        end
    end
    
    methods % Matrix manipulation
        function x = horzcat(varargin)
            vector = [];
            for k=1:length(varargin)
                elem = varargin{k};
                vector = horzcat(vector, elem.Value);
            end
            x = copy(elem);
            x.Value = vector;
        end
        
        function x = vertcat(varargin)
            vector = [];
            for k=1:length(varargin)
                elem = varargin{k};
                vector = vertcat(vector, elem.Value);
            end
            x = copy(elem);
            x.Value = vector;
        end
        
        function x = subsref(obj, s)
            
            if strcmp(s.type, '()') && isa(s.subs{1}, 'YopVar')
                if s.subs{1}.isIndependentInitial
                    x = YopVarTimed(obj.Value, YopVar.getIndependentInitial.Value);
                    
                elseif s.subs{1}.isIndependentFinal
                    x = YopVarTimed(obj.Value, YopVar.getIndependentFinal.Value);                    
                    
                end
                
            elseif strcmp(s.type, '()') && isa(s.subs{1}, 'YopTimepoint')
                x = YopVarTimed(obj.Value, s.subs{1}.Timepoint);
                
            elseif strcmp(s.type, '()')
                v = obj.Value;
                x = YopVar( v(s.subs{:}) );
                
            elseif strcmp(s.type, '{}')
                v = obj.value;
                x = YopVar( v{s.subs{:}} );
                
            elseif strcmp(s.type, '.')
                x = obj.(s.subs);
                
            end
        end
        
        function x = subsasgn(x, s, y)                            
            if strcmp(s.type, '()')
                expr = x.Value;
                expr(s.subs{:}) = y;
                
            elseif strcmp(s.type, '{}')
                expr = x.Value;
                expr{s.subs{:}} = y;
                
            elseif strcmp(s.type, '.')
                x.(s.subs) = y;
                
            end
        end     
    end
        
    methods % Math
        function y = integral(x)
            y = YopIntegral(x.Value);
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
            z = YopVar.twoArgOperation(x, y, @times);
        end
        
        function z = mtimes(x, y)
            z = YopVar.twoArgOperation(x, y, @mtimes);
        end
        
        function z = rdivide(x, y)
            z = YopVar.twoArgOperation(x, y, @rdivide);
        end
        
        function z = ldivide(x, y)
            z = YopVar.twoArgOperation(x, y, @ldivide);
        end        
        
        function z = mrdivide(x, y)
            z = YopVar.twoArgOperation(x, y, @mrdivide);
        end
        
        function z = mldivide(x, y)
            z = YopVar.twoArgOperation(x, y, @mldivide);
        end
        
        function z = power(x, y)
           z = YopVar.twoArgOperation(x, y, @power); 
        end
        
        function z = mpower(x, y)
           z = YopVar.twoArgOperation(x, y, @mpower); 
        end  
        
        function y = exp(x)
            y = copy(x);
            y.Value = exp(x.Value);
        end
        
        function y = sign(x)
            y = copy(x);
            y.Value = sign(x.Value);
        end
        
        function y = ctranspose(x)
            y = copy(x);
            y.Value = ctranspose(x.Value);
        end
        
        function y = transpose(x)
            y = copy(x);
            y.Value = transpose(x.Value);
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
    end
    
    methods (Static)
        function v = variable(varargin)
            persistent ip
            if isempty(ip)
                ip = inputParser;
                ip.FunctionName = 'YopVar.variable';
                ip.PartialMatching = false;
                ip.CaseSensitive = true;
                ip.addOptional('symbol', 'v', @(x) true);
                ip.addOptional('rows', 1, @(x) true);
                ip.addOptional('columns', 1, @(x) true);
            end
            ip.parse(varargin{:});
            
            v = YopVar(casadi.MX.sym( ...
                  ip.Results.symbol, ...
                  ip.Results.rows, ...
                  ip.Results.columns ...
                ));
        end
        
        function t = getIndependent()
            persistent independent
            if isempty(independent)
                yopCustomPropertyNames;
                independent = YopVar.variable(userIndependentVariableProperty);
            end
            t = independent;
        end
        
        function t = getIndependentInitial()
            persistent independent
            if isempty(independent)
                yopCustomPropertyNames;
                independent = YopVar.variable(userIndependentInitial);
            end
            t = independent;
        end
        
        function t = getIndependentFinal()
            persistent independent
            if isempty(independent)
                yopCustomPropertyNames;
                independent = YopVar.variable(userIndependentFinal);
            end
            t = independent;
        end
        
    end
    
    methods (Static, Access=private)        
        function res = twoArgOperation(x, y, op)
            [x, y] = YopVar.convert(x, y);
            
            if areEqual(x, y) 
                % Note! This means that some derived classes need to 
                % specify YopVar as inferior and overload areEqual
                res = copy(x);
                res.Value = op(x.Value, y.Value);
                
            else
                res = YopVarGraph(op, x, y);
                
            end
        end
        
        function [x, y] = convert(x, y)
            if ~isa(x, 'YopVar')
                tmp = copy(y);
                tmp.Value = x;
                x = tmp;
                
            elseif ~isa(y, 'YopVar')
                tmp = copy(x);
                tmp.Value = y;
                y = tmp;
                
            end
        end        
    end
end