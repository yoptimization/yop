classdef (InferiorClasses = {?YopVar}) YopVarTimed < YopVar
    
    properties
        Timepoint
    end
    
    methods
        function obj = YopVarTimed(expression, timepoint)
            obj@YopVar(expression);
            obj.Timepoint = timepoint;
        end        
        
        function val = evaluateAtTimepoint(obj, timepoint, nlpVariables)
           %
           assert(false, 'to be implemented')
        end
        
    end    
    
    methods % YopVar/-Graph interface        
        function bool = areEqual(x, y)
            if isequal(class(x), class(y))
                bool = isequal(x.Timepoint, y.Timepoint);
            else
                bool = false;
            end
        end
        
    end
end