classdef relation < yop.node & yop.more_stupid_overhead
    methods
        function obj = relation(name, rows, columns, relation)
            obj@yop.node(name, rows, columns);
            obj.relation = relation;
        end
        
        function obj = forward(obj)
            args = cell(size(obj.child.elem));
            for k=1:size(args,2)
                args{k} = obj.child.elem(k).object.value;
            end
            obj.value = obj.relation(args{:});
        end
    end
end