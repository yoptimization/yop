classdef VariableGraphInterface < handle
    methods (Abstract)
        bool = isIndependentInitial(obj);
        bool = isIndependentFinal(obj);
        bool = isaVariable(obj);
        bool = isnumeric(obj);
    end
end