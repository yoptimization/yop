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
        
        
        function graph = split(obj)
            % parsing the following structure
            %         r3
            %        / \
            %       r2  e4
            %      / \
            %     r1  e3
            %    /\
            %  e1 e2
            %
            % Splits into
            %   r1     r2     r3
            %  /  \   /  \   /  \
            % e1  e2 e2  e3 e3  e4
            %
            % e1 < e2 < e3 < e4 => {e1 < e2, e2 < e3, e3 < e4}
            
            if isa(obj, 'yop.relation') && ~isa(left(obj),'yop.relation') && ~isa(right(obj),'yop.relation')
                % This is the end node.
                graph = {obj};
                
            elseif isa(obj, 'yop.relation') && isa(left(obj),'yop.relation') && ~isa(right(obj),'yop.relation')
                r = yop.relation(obj.name, obj.rows, obj.columns, obj.relation);
                set_child(r, right(left(obj)));
                set_child(r, right(obj));
                set_parent(right(left(obj)), r);
                graph = [split(left(obj)); {r}];
                
            else
                yop.assert(false, yop.messages.graph_not_valid);
                
            end
        end
        
        function r = nlp_form(obj)
            % changes the following form:
            %     r
            %    / \
            %   e1 e2
            % into:
            %      r
            %    /   \
            %  e1-e2  0
            if ~isa(obj, 'yop.relation') || isa(left(obj), 'yop.relation') || isa(right(obj), 'yop.relation')
                yop.assert(false, yop.messages.graph_not_simple);
                
            else
                e = yop.operation('-', obj.rows, obj.columns, @minus);
                set_child(e, left(obj));
                set_child(e, right(obj));
                set_parent(left(obj), e);
                set_parent(right(obj), e);
                
                z = yop.constant('0', obj.rows, obj.columns);
                z.value = zeros(size(obj));
                
                r = yop.relation(obj.name, obj.rows, obj.columns, obj.relation);
                set_child(r, e);
                set_child(r, z);
                set_parent(e, r);
                set_parent(z, r);
            end
        end
        
        
    end
end