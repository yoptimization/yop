classdef Variable < Yop.MathOperations & Yop.VariableGraphInterface & Yop.DefaultChangingBehavior & matlab.mixin.Copyable
    
    properties
        Value
    end
    
    methods
        function obj = Variable(expression)
            obj.Value = expression;
        end
        
        function obj = replace(obj, newValue)
            obj.Value = newValue;
        end
        
        function disp(obj)
            disp(obj.Value);
        end
        
        function display(obj)
            eval([inputname(1) '= obj.Value']);
        end
        
    end
    
    methods % YopVar/-Graph Interface
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
        
         function node = findSubNodes(obj, criteria)
             try criteria(obj)
                 node = obj;
             catch
                 node = [];
             end
         end
        
        function bool = dependsOn(obj, variable)
            bool = isequal(obj, variable);
            % bool = depends_on(obj.evaluateComputation, evaluateComputation(variable));
        end
        
        function bool = graphIsaExpression(obj)
            bool = true;
        end
        
        function bool = nodeIsaRelation(obj)
            bool = false;
        end
        
        function bool = isIndependentInitial(obj)
            bool = isequal(obj, Yop.getIndependentInitial);
        end
        
        function bool = isIndependentFinal(obj)
            bool = isequal(obj, Yop.getIndependentFinal);
        end
        
        function bool = isaVariable(obj)
            bool = ~isnumeric(obj);
        end
        
        function bool = isaNumeric(obj)
            bool = isnumeric(obj.Value);
        end
        
        function expression = t0(obj)
            expression = Yop.ComputationalGraph(@(obj) obj, obj);
            t0(expression);            
        end
        
        function expression = tf(obj)
            expression = Yop.ComputationalGraph(@(obj) obj, obj);
            tf(expression);
        end
        
        function expression = ti(obj, t_i)
            expression = Yop.ComputationalGraph(@(obj) obj, obj);
            ti(expression, t_i);
        end
    end
    
    methods % DefaultChangingBehavior
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
        
        function ind = end(obj,k,n)
            szd = size(obj.Value);
            if k < n
                ind = szd(k);
            else
                ind = prod(szd(k:end));
            end
        end
    end
    
end