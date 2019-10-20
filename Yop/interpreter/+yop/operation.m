classdef operation < yop.node & yop.stupid_overhead
    properties
        timepoint
        index
    end
    methods
        
        function obj = operation(name, rows, cols, operation)
            obj@yop.node(name, rows, cols);
            obj.operation = operation;
        end
        
        function obj = forward(obj)
            args = cell(size(obj.child.elem));
            for k=1:size(args,2)
                args{k} = obj.child.elem(k).object.value;
            end
            obj.value = obj.operation(args{:});
        end
        
    end
end