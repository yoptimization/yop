classdef node < handle
    
    properties
        name % Name of the node.
    end
    
    properties (SetObservable, AbortSet)
        value % Value associated with node.
    end
    
    properties (Hidden, SetAccess=protected)
        rows    % Number of rows.
        columns % Number of columns.
        parent  % Parent nodes. Is proteced beacuse it needs a listener.
        child   % Child nodes.
    end
    
    properties (SetAccess=private, GetAccess=private)
        eval_order
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
            obj.parent = yop.node_listener_list();
            obj.child = yop.list();
        end
        
        function obj = set_parent(obj, parent)
            listener = addlistener(obj, 'value', 'PostSet', @parent.clear);
            add(obj.parent, parent, listener);
        end
        
        function obj = remove_parent(obj, parent)
            remove(obj.parent, parent);
        end
        
        function obj = set_child(obj, child)
            % Lyssnare?
            add(obj.child, child);
        end
        
        function obj = remove_child(obj, child)
            % Ta bort lyssnare.
            remove(obj.child, child);
        end
        
        function clear(obj, ~, ~)
            if isvalid(obj)
                obj.value = [];
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
            visited = yop.list;
            ordering = yop.list;
            
            function recursion(node)
                if isa(node, 'yop.operation')
                    for k=1:length(node.child.elem)
                        if ~visited.contains(node.child.elem(k).object)
                            recursion(node.child.elem(k).object);
                        end
                    end
                end
                add(visited, node);
                add(ordering, node);
            end
            
            recursion(obj);
            obj.eval_order = ordering;
        end
        
        function value = evaluate(obj)
            if isempty(obj.eval_order)
                order_nodes(obj);
            end
            for k=1:length(obj.eval_order.elem)
                forward(obj.eval_order.elem(k).object);
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


