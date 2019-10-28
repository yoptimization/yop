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
            
            if isa(obj, 'yop.relation') && ~isa(obj.left, 'yop.relation') && ~isa(obj.right, 'yop.relation')
                % This is the end node.
                graph = yop.node_list().add(obj);
                
            elseif isa(obj, 'yop.relation') && isa(obj.left, 'yop.relation') && ~isa(obj.right, 'yop.relation')
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
        
        function r = general_form(obj)
            % changes the following form:
            %     r
            %    / \
            %   e1 e2
            % into:
            %      r
            %    /   \
            % e1-e2   0
            %
            
            if ~isa(obj, 'yop.relation') || isa(obj.left, 'yop.relation') || isa(obj.right, 'yop.relation')
                yop.assert(false, yop.messages.graph_not_simple);
                
            else
                r = obj.relation(obj.left-obj.right, 0);
                
            end
            
        end
        
        function r = nlp_form(obj)
            % Requires graph is on general form.
            % If not on nlp form creates a new graph according to: 
            %  e <  0  -->   e <= 0
            %  e <= 0   =    e <= 0
            %  e >  0  -->  -e <= 0
            %  e >= 0  -->  -e <= 0
            %  e == 0   =    e == 0
            if isequal(obj.relation, @lt)
                r = obj.left <= 0;
                
            elseif isequal(obj.relation, @gt) || isequal(obj.relation, @ge)
                r = -1*obj.left <= 0;
                
            else
                r = obj;
                
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