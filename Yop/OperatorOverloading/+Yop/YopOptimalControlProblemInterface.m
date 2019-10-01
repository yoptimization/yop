classdef YopOptimalControlProblemInterface < handle
    methods (Abstract)
        value = evaluate(obj);
        bool = isaRelation(obj);
        bool = isaExpression(obj);
        bool = isaVariable(obj);
        bool = isnumeric(obj);
        bool = areEqual(x, y);
        nargs = numberOfInputArguments(obj);
        args = getInputArguments(obj);
        bool = dependsOn(obj, variable);
        bool = isaBox(obj);
        bool = isaEquality(obj);
        bool = isaUpperBound(obj);
        bool = isaLowerBound(obj);
        bd = getBound(obj);
        ub = getUpperBound(obj);
        lb = getLowerBound(obj);
        graph = unnestRelation(obj);
        nlpGraph = setToNlpForm(obj);
        obj = replace(obj, newValue);        
    end
end