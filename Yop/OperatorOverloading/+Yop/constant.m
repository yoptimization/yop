classdef constant < yop.node
    properties
        name
    end
    methods
        
        function obj = constant(name, value)
            [rows, cols] = size(value);
            obj@yop.node(name, rows, cols);
            obj.value = value;
        end       
        
    end
end