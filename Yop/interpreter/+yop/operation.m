classdef operation < yop.node & yop.stupid_overhead
    properties
        timepoint
        index
    end
    methods
        
        function obj = operation(name, rows, columns, operation)
            obj@yop.node(name, rows, columns);
            obj.operation = operation;
        end
        
        function obj = forward(obj)
            args = cell(size(obj.children));
            for k=1:size(args,2)
                args{k} = obj.child(k).value;
            end
            obj.value = obj.operation(args{:});
        end
        
    end
end