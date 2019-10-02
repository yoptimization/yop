classdef FunctionException < handle
    properties
        Function
        Substitute
    end
    methods
        
        function obj = FunctionException(original, substitute)
            obj.Function = original;
            obj.Substitute = substitute;
        end
        
        function bool = isaException(obj, func)
            bool = false;
            for k=1:length(obj)
                if isequal(obj(k).Function, func)
                    bool = true;                    
                    break;
                end
            end
        end
        
        function substitute = getSubstitute(obj, func)
            for k=1:length(obj)
                if isequal(obj(k).Function, func)
                    substitute = obj(k).Substitute;                    
                    break;
                end
            end
        end
        
    end
    methods (Static)
        function exceptions = getExceptions
            persistent exception
            if isempty(exception)
                Yop.functionExceptionList;
                exception = e;
            end
            exceptions = exception;
        end        
    end
end