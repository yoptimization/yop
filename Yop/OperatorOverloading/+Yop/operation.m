classdef operation < yop.node
    properties
        operation_handle
        timepoint
        index
    end
    methods
        
        function obj = operation(name, rows, cols, operation_handle, child_pointer)
            obj@yop.node(name, rows, cols);
            obj.operation_handle = operation_handle;
            obj.child = child_pointer;
        end
        
        function value = forward(obj)
            child = obj.child.get_object();
            args = cell(size(child));
            for k=1:size(args,2)
                args{k} = child{k}.value;
            end
            value = obj.operation_handle(args{:});
            obj.value = value;
        end
        
    end
end