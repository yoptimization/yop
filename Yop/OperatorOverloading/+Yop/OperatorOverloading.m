classdef OperatorOverloading < handle
    methods
        function x = horzcat(varargin)
            x = Yop.ComputationalGraph(@horzcat, varargin{:});
        end
        
        function x = vertcat(varargin)
            x = Yop.ComputationalGraph(@vertcat, varargin{:});
        end
    end
end