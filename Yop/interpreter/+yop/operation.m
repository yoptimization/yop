classdef operation < yop.node
    methods
        
        function obj = operation(name, size, operation)
            obj@yop.node(name, size);
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