classdef Expression < Yop.MathOperations & Yop.OperatorOverloading & matlab.mixin.Copyable
    
    properties
        Value
        Timepoint
        Index
    end
    
    methods
        function obj = Expression(expression, timepoint)
            obj.Value = expression;
            if nargin == 2
                obj.Timepoint = timepoint;
            end
        end
        
        function obj = t0(obj)
            obj.Timepoint = Yop.getIndependentInitial;
        end
        
        function obj = tf(obj)
            obj.Timepoint = Yop.getIndependentFinal;
        end
        
        function obj = ti(obj, ti)
            obj.Timepoint = ti;
        end
        
        function v = value(obj)
            v = obj.Value;
        end
        
%         function disp(obj)
%             disp(obj.Value);
%         end
%         
%         function display(obj)
%             eval([inputname(1) '= obj.Value']);
%         end
        
        function bool = isIndependentInitial(obj)
            bool = isequal(obj, Yop.getIndependentInitial);
        end
        
        function bool = isIndependentFinal(obj)
            bool = isequal(obj, Yop.getIndependentFinal);
        end
        
        function bool = isaVariable(obj)
            bool = ~isnumeric(obj);
        end
        
        function bool = isnumeric(obj)
            bool = isnumeric(obj.Value);
        end
        
        function obj = replace(obj, newValue)
            obj.Value = newValue.Value;
        end
        
        function bool = dependsOn(obj, variable)
            % Kan vi hitta den här variabeln i den här grafen?    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!            
            bool = depends_on(obj.evaluateComputation, evaluateComputation(variable));
        end
    end
    
    methods % YopVar/-Graph Interface
        function bool = areEqual(x, y)
            if isequal(class(x), class(y))
                bool = isequal(x.Timepoint, y.Timepoint);
            else
                bool = false;
            end
        end
        
        function value = evaluateComputation(obj)
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
        
        function [s, varargout] = size(obj, varargin)
            s = size(obj.Value, varargin{:});
            nout = max(nargout,1) - 1;
            for k=1:nout
                varargout{k} = s(k);
            end
        end
        
        function n = numel(obj)
            n = numel(obj.Value);
        end
        
        function n = numArgumentsFromSubscript(obj, s, indexingContext)
            n = 1;
        end
        
        function ind = end(obj,k,n)
            szd = size(obj.Value);
            if k < n
                ind = szd(k);
            else
                ind = prod(szd(k:end));
            end
        end      
        
        function varargout = subsref(obj, s)
            
            if isempty(s)
                varargout{1} = obj;
                
            elseif strcmp(s(1).type, '()') && length(s) > 1
                v = obj.Value;
                varargout{1} = subsref(Yop.Expression(v(s(1).subs{:})), s(2:end));
                
            elseif strcmp(s(1).type, '{}') && length(s) > 1
                v = obj.value;
                varargout{1} = subsref(Yop.Expression(v{s(1).subs{:}}), s(2:end));
                
            elseif strcmp(s(1).type, '.') && length(s) > 1 && ismethod(obj, s(1).subs)
                narg = nargin(['Yop.Expression>Yop.Expression.' s(1).subs ]);
                
                if narg ~= 1 && length(s) == 2
                    varargout{1} = obj.(s(1).subs)(s(2).subs{:});
                    
                elseif narg ~= 1
                    varargout{1} = subsref(obj.(s(1).subs)(s(2).subs{:}), s(3:end));
                    
                else
                    varargout{1} = subsref(obj.(s(1).subs), s(2:end));
                    
                end
                
            elseif strcmp(s(1).type, '.') && length(s) > 1 && isprop(obj, s(1).subs)
                varargout{1} = subsref(obj.(s(1).subs), s(2:end));             
                
            elseif strcmp(s.type, '{}')
                v = obj.value;
                varargout{1} = Yop.Expression( v{s.subs{:}} );
                
            elseif strcmp(s.type, '.')
                varargout{1} = obj.(s.subs);
                
            elseif strcmp(s.type, '()') && isnumeric(s.subs{1})
                v = obj.Value;
                varargout{1} = Yop.Expression( v(s.subs{:}) );
                
            elseif strcmp(s.type, '()') && isa(s.subs{1}, 'YopTimepoint')
                varargout{1} = Yop.Expression(obj.Value, s.subs{1}.Timepoint);
                
            elseif strcmp(s.type, '()') && isIndependentInitial(s.subs{1})
                obj.Timepoint = Yop.getIndependentInitial;
                varargout{1} = obj;
                
            elseif strcmp(s.type, '()') && isIndependentFinal(s.subs{1})
                obj.Timepoint = Yop.getIndependentFinal;
                varargout{1} = obj;
                
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
    
end