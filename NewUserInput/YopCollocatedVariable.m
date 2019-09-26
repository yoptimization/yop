classdef YopCollocatedVariable < YopCollocatedSignal
    methods
        function obj = YopCollocatedVariable(label, dimension, degree, points, range)
            coefficients = [];
            for r=1:degree+1
                coefficients = [coefficients, ...
                    YopVar.variable(label(r), dimension)];
            end
            obj@YopCollocatedSignal(coefficients, degree, points, range);
        end
    end    
end