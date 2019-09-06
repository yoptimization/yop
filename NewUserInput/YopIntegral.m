classdef (InferiorClasses = {?YopVar}) YopIntegral < YopVar
    % Vid namnbyte glöm ej att ändra inferior i YopVarGraph
    methods
        function obj = YopIntegral(expression)
            obj@YopVar(expression);
        end
        
        function bool = areEqual(x, y)
            bool = false;
        end
    end
end