classdef YopMultiPhaseOptions < handle
    properties
        ContinuousState
        ContinuousControl
        FixedParameter
    end
    methods
        function obj = YopMultiPhaseOptions(continuousState, continuouseControl, fixedParameter)
            obj.ContinuousState = continuousState;
            obj.ContinuousControl = continuouseControl;
            obj.FixedParameter = fixedParameter;
        end
    end
end