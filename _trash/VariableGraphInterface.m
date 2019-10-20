classdef VariableGraphInterface < handle
    methods (Abstract)
        % These must also exist as functions (for numerics to access)
        result = evaluateComputation(obj)
        n = numberOfNodes(obj);
        o = getOperations(obj);
        n = numberOfInputArguments(obj)
        i = getInputArguments(obj);   
        le = leftmostExpression(obj);        
        re = rightmostExpression(obj);
        node = findSubNodes(obj, criteria);
        bool = dependsOn(obj, variable);
        bool = graphIsaExpression(obj);        
        bool = nodeIsaRelation(obj);
        bool = isIndependentInitial(obj);
        bool = isIndependentFinal(obj);
        bool = isaVariable(obj);
        bool = isaNumeric(obj);
        obj = t0(obj);
        obj = tf(obj);
        obj = ti(obj, t_i);
    end
end