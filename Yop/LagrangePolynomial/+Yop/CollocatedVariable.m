classdef CollocatedVariable < Yop.CollocatedSignal
    methods
        function obj = CollocatedVariable(label, dimension, points, degree, range)
            coefficients = [];
            for r=1:degree+1
                coefficients = [coefficients, ...
                    Yop.YopVar(label(r), dimension)];
            end
            obj@Yop.CollocatedSignal(coefficients, points, degree, range);
        end
    end    
end