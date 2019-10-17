classdef operation < yop.node
    properties
        op
        timepoint
        index
    end
    methods
        
        function obj = operation(name, rows, cols, op)
            obj@yop.node(name, rows, cols);
            obj.op = op;
        end
        
        function value = forward(obj)
            if obj.stored_value
                value = obj.value;
            else
                args = cell(size(obj.child));
                for k=1:size(args,2)
                    args{k} = obj.child(k).object.value;
                end
                value = obj.op(args{:});
                obj.value = value;
                obj.stored_value = true;
            end
        end
        
    end
end