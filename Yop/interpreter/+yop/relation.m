classdef relation < yop.node & yop.more_stupid_overhead
    methods
        function obj = relation(name, rows, columns, relation)
            obj@yop.node(name, rows, columns);
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
        
        function bool = isa_upper_bound(obj)
            % Tests if a box constraint is an upper bound that is:
            % test if the object is one of the following:
            %   v <= c
            %   c >= v
            bool = obj.isa_upper_type1 || obj.isa_upper_type2;
        end
        
        function bool = isa_upper_type1(obj)
            % test if it is a box constraint of the following type:
            %   variable <= constant
            bool = obj.isa_type1_box_constraint(@lt, @le);
        end
        
        function bool = isa_upper_type2(obj)
            % test if it is a box constraint of the following type:
            %    constant >= variable
            bool = obj.isa_type2_box_constraint(@gt, @ge);
        end
        
        function bool = isa_lower_bound(obj)
            % Tests if a box constraint is an upper bound that is:
            % test if the object is one of the following:
            %   v >= c
            %   c <= v
            bool = obj.isa_lower_type1 || obj.isa_lower_type2;
        end
        
        function bool = isa_lower_type1(obj)
            % test if it is a box constraint of the following type:
            %   variable >= constant
            bool = obj.isa_type1_box_constraint(@gt, @ge);
        end
        
        function bool = isa_lower_type2(obj)
            % test if it is a box constraint of the following type:
            %    constant <= variable
            bool = obj.isa_type2_box_constraint(@lt, @le);
        end
        
        function bool = isa_equality_type1(obj)
            % test if it is a box constraint of the following type:
            %   variable == constant
            bool = obj.isa_type1_box_constraint(@eq, @eq);
        end
        
        function bool = isa_equality_type2(obj)
            % test if it is a box constraint of the following type:
            %    constant == variable
            bool = obj.isa_type2_box_constraint(@eq, @eq);
        end
        
        function bool = isa_type1_box_constraint(obj, op1, op2)
            % test if it is a box constraint of the following type:
            %   varaible [relation] constant.
            %   example upper bound: v <= c
            %   example lower bound: v >= c
            bool = isa_box(obj) && ...
                isa_variable(obj.left) && ...
                isa(obj.right, 'yop.constant') && ...
                (isequal(obj.relation, op1) || isequal(obj.relation, op2));
        end
        
        function bool = isa_type2_box_constraint(obj, op1, op2)
            % test if it is a box constraint of the following type:
            %   constant [relation] varaible.
            %   example lower bound: c <= v
            %   example upper bound: c >= v
            bool = isa_box(obj) && ...
                isa(obj.left, 'yop.constant') && ...
                isa_variable(obj.right) && ...
                (isequal(obj.relation, op1) || isequal(obj.relation, op2));
        end
        
        
        
        
    end
end





















