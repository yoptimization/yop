classdef (InferiorClasses = {?YopVar}) YopIntegral < YopVar
    methods
        function obj = YopIntegral(expression)
            obj@YopVar(expression);
        end
        
        function bool = areEqual(x, y)
            bool = false;
        end
    end
end