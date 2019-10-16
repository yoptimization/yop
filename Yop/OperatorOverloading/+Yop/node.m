classdef node < handle
    
    properties
        name
        parent
        child
        rows
        columns
        pointer
        ordering
    end
    
    properties (SetAccess=protected)
        value
    end
    
    methods
        
        function obj = node(name, rows, columns)
            if nargin == 1
                rows = 1;
                columns = 1;
            elseif nargin == 2
                columns = 1;
            end
            obj.name = name;
            obj.rows = rows;
            obj.columns = columns;
            obj.pointer = yop.pointer(obj);
        end
        
        function obj = set_value(obj, value)
            obj.value = value;
        end
        
        
        function obj = set_parent(obj, pointer)
            if isempty(obj.parent)
                obj.parent = pointer;
            else
                obj.parent(end+1) = pointer;
            end
        end
        
        function obj = set_child(obj, pointer)
            if isempty(obj.parent)
                obj.child = pointer;
            else
                obj.child(end+1, end+1+size(pointer,2)) = pointer;
            end
        end
        
        function s = size(obj, dim)
            if nargin == 2
                if dim == 1
                    s = obj.rows;
                elseif dim == 2
                    s = obj.columns;
                else
                    yop.assert(false, ['Variables are matrix valued.', ...
                        'A call to dimension ' num2str(dim) ...
                        ' is therefore not possible.'])
                end
            else
                s = [obj.rows, obj.columns];
            end
        end
        
        
        function z = plus(x, y)
            % typecast
            
            sx = size(x);
            sy = size(y);
            yop.assert(isequal(sx, sy) || isscalar(x) || isscalar(y), ...
                ['Wrong dimensions for operation "+".' ...
                'You have: [' num2str(sx) '] and [' num2str(sy) '].']);
            
            z_rows = max(sx(1), sy(1));
            z_cols = max(sx(2), sy(2));
            z = yop.operation('plus', z_rows, z_cols, @plus, [x.pointer, y.pointer]);
            x.set_parent(z.pointer);
            y.set_parent(z.pointer);
            
        end
        
        function obj = order_nodes(obj)
            visited = yop.pointer;
            evaluation_order = yop.pointer;            
            
            function recursion(node)
                if isa(node, 'yop.operation')
                    for k=1:length(node.child)
                        if ~visited.contains(node.child(k))
                            recursion(node.child(k).object);
                        end
                    end
                end
                if isempty(visited(1).object)
                    visited(end+1) = node.pointer;
                else
                    visited(end+1) = node.pointer;
                end
                if isempty(evaluation_order(1).object)
                    evaluation_order = node.pointer;
                else
                    evaluation_order(end+1) = node;
                end
                
            end
            
            recursion(obj);            
            obj.ordering = evaluation_order;
            
        end
        
        function value = evaluate(obj)
            order_nodes(obj);
            for k=1:length(obj.ordering)
                forward(obj.ordering(k).object);
            end
            value = obj.value;
        end
        
    end
    
end

























