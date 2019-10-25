classdef relation < yop.node & yop.more_stupid_overhead
    methods
        function obj = relation(name, rows, columns, relation)
            obj@yop.node();
            obj.init(name, rows, columns)
            obj.relation = relation;
        end
        
        function obj = forward(obj)
            args = cell(size(obj.children));
            for k=1:size(args,2)
                args{k} = obj.child(k).value;
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
                graph = yop.list().add(obj);
                
            elseif isa(obj, 'yop.relation') && isa(left(obj),'yop.relation') && ~isa(right(obj),'yop.relation')
                r = yop.relation(obj.name, obj.rows, obj.columns, obj.relation);
                r.set_child(obj.left.right);
                r.set_child(obj.right);
                obj.left.right.set_parent(r);
                graph = obj.left.split.add(r);
                %  graph = obj.left.split.concatenate(yop.list().add(r));
                
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
            % e1-e2   0
            %
            % Ändra operator också.
            % Denna funktion borde heta general_form()
            % implementationen borde vara att man kan ta vilket uttryck som
            % helt, sedan splittas det, görs till generell form och sedan
            % ändras operatorn:
            % nodes = node.nlp_form => node.split.general_form ändra op.
            % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            if ~isa(obj, 'yop.relation') || isa(left(obj), 'yop.relation') || isa(right(obj), 'yop.relation')
                yop.assert(false, yop.messages.graph_not_simple);
                
            else
                e = yop.operation('-', obj.rows, obj.columns, @minus);
                e.set_child(obj.left);
                e.set_child(obj.right);
                obj.left.set_parent(e);
                obj.right.set_parent(e);
                
                z = yop.constant('0', obj.rows, obj.columns);
                z.value = zeros(size(obj));
                
                r = yop.relation(obj.name, obj.rows, obj.columns, obj.relation);
                r.set_child(e);
                r.set_child(z);
                e.set_parent(r);
                z.set_parent(r);
            end
        end
        
        function bool = isa_box(obj)
            % Tests if the following structure (r=relation, e=expression):
            %      r
            %     / \
            %    e1 e2
            % is a box constraint.
            % Notice that it doesn't test if the strucure is correct.
            bool = obj.left.isa_variable && isa(obj.right, 'yop.constant') || ...
                isa(obj.left, 'yop.constant') && obj.right.isa_variable;
        end
        
        
    end
end