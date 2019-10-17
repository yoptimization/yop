classdef node < handle
    
    properties (SetAccess=protected)
        name
    end
    
    properties (Hidden, SetAccess=protected)
        rows
        columns
        parent
        child
        value
        stored_value
    end
    
    properties(SetAccess=private, GetAccess=private)
        pointer
        eval_order
        order_stored
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
            obj.stored_value = false;
            obj.order_stored = false;
        end
        
        function obj = set_parent(obj, parent)
            if isempty(obj.parent)
                obj.parent = parent.pointer;
            else
                obj.parent(end+1) = parent;
            end
        end
        
        function obj = set_child(obj, child)
            if isempty(obj.child)
                obj.child = child.pointer;
            else
                obj.child(end+1) = child;
            end
            obj.order_stored = false;
        end
        
        function obj = set_value(obj, value)
            obj.value = value;
            for k=1:length(obj.parent)
                input_changed_value(obj.parent(k).object);
            end
        end
        
        function obj = input_changed_value(obj)
            obj.stored_value = false;
            for k=1:length(obj.parent)
                input_changed_value(obj.parent(k).object);
            end
        end
        
    end
    
    methods % Default changing behavior
        
        function s = size(obj, dim)
            if nargin == 2
                if dim == 1
                    s = obj.rows;
                elseif dim == 2
                    s = obj.columns;
                else
                    yop.assert(false, yop.messages.error_size(dim))
                end
            else
                s = [obj.rows, obj.columns];
            end
        end
        
    end
    
    methods % Computational graph
        
        function obj = order_nodes(obj)            
            visited = yop.pointer;
            ordering = yop.pointer;
            
            function recursion(node)
                if isa(node, 'yop.operation')
                    for k=1:length(node.child)
                        if ~visited.contains(node.child(k))
                            recursion(node.child(k).object);
                        end
                    end
                end
                visited(end+1) = node;
                ordering(end+1) = node;
            end
            
            recursion(obj);
            obj.eval_order = ordering(2:end);  
            obj.order_stored = true;
        end
        
        function value = evaluate(obj)
            if ~obj.order_stored
                order_nodes(obj);
            end
            for k=1:length(obj.eval_order)
                forward(obj.eval_order(k).object);
            end
            value = obj.value;
        end
        
    end
    
    methods % ool
        
        function z = plus(x, y)
            % typecast
            
            sx = size(x);
            sy = size(y);
            
            cond = isequal(sx, sy) || isscalar(x) || isscalar(y);
            yop.assert(cond, yop.messages.error_plus(sx, sy));
            
            z_rows = max(sx(1), sy(1));
            z_cols = max(sx(2), sy(2));
            z = yop.operation('plus', z_rows, z_cols, @plus);
            z.set_child(x);
            z.set_child(y);
            x.set_parent(z);
            y.set_parent(z);
        end
        
    end
    
end

























