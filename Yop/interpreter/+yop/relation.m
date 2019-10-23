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
        
        
        
        function graph = unnest(obj)
            % Interprets graph as a constraint and unnest relations in the
            % graph from left to right. May brake down if graph is not a
            % valid constraint.
            % I.e. -1 <= f(x) <= 1 turns into:
            %  -1 <= f(x)
            %  f(x) <= 1
            
            if isa_expression(left(obj)) && isa_expression(right(obj)) && isa(obj, 'yop.relation')
                graph = {obj};
                
            elseif isa_expression(left(obj)) && isa(right(obj), 'yop.relation') && isa(obj, 'yop.relation')
                lhs = yop.relation(obj.name, obj.rows, obj.columns, obj.relation);
                lmr = leftmost(right(obj));
                set_child(lhs, left(obj));
                set_child(lhs, lmr);
                set_parent(lmr, lhs);
                rhs = unnest(right(obj));
                graph = [{lhs}; rhs(:)];
                
            elseif isa(left(obj), 'yop.relation') && isa_expression(right(obj)) && isa(obj, 'yop.relation')
                lhs = unnest(left(obj));
                rhs = yop.relation(obj.name, obj.rows, obj.columns, obj.relation);
                rml = rightmost(left(obj));
                set_child(rhs, rml);
                set_child(rhs, right(obj));
                set_parent(rml, rhs);
                graph = [lhs(:); {rhs}];
                
            elseif isa(left(obj), 'yop.relation') && isa(right(obj), 'yop.relation') && isa(obj, 'yop.relation')
                lhs = unnest(left(obj));
                rhs = unnest(right(obj));
                mdl = yop.relation(obj.name, obj.rows, obj.columns, obj.relation);
                rml = rightmost(left(obj));
                lmr = leftmost(right(obj));
                set_child(mdl, rml);
                set_child(mdl, lmr);
                set_parent(rml, mdl);
                set_parent(lmr, mdl);
                graph = [lhs(:); {mdl}; rhs(:)];
                
            else
                yop.assert(false, yop.messages.graph_not_relation);
                
            end
        end
    end
end