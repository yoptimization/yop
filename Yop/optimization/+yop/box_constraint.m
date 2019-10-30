classdef box_constraint < yop.relation
   
    methods (Static)
        function bool = isa_box(relation)
            % Tests if the following structure (r=relation, e=expression):
            %      r
            %     / \
            %    e1 e2
            % is a box constraint.
            % Notice that it doesn't test if the strucure is correct.
            bool = relation.left.isa_variable && isa(relation.right, 'yop.constant') || ...
                isa(relation.left, 'yop.constant') && relation.right.isa_variable;
        end
        
        function bool = isa_upper_bound(relation)
            % Tests if a box constraint is an upper bound that is:
            % test if the object is one of the following:
            %   v <= c
            %   c >= v
            bool = yop.box_constraint.isa_upper_type1(relation) || ...
                yop.box_constraint.isa_upper_type2(relation);
        end
        
        function bool = isa_upper_type1(relation)
            % test if it is a box constraint of the following type:
            %   variable <= constant
            bool = yop.box_constraint.isa_type1(relation) && ...
                (isequal(relation.relation, @lt) || isequal(relation.relation, @le));
        end
        
        function bool = isa_upper_type2(relation)
            % test if it is a box constraint of the following type:
            %    constant >= variable
            bool = yop.box_constraint.isa_type2(relation) && ...
                (isequal(relation.relation, @gt) || isequal(relation.relation, @ge));
        end
        
        function bool = isa_lower_bound(relation)
            % Tests if a box constraint is an upper bound that is:
            % test if the object is one of the following:
            %   v >= c
            %   c <= v
            bool = yop.box_constraint.isa_lower_type1(relation) || ...
                yop.box_constraint.isa_lower_type2(relation);
        end
        
        function bool = isa_lower_type1(relation)
            % test if it is a box constraint of the following type:
            %   variable >= constant
            bool = yop.box_constraint.isa_type1(relation) && ...
                (isequal(relation.relation, @gt) || isequal(relation.relation, @ge));
        end
        
        function bool = isa_lower_type2(relation)
            % test if it is a box constraint of the following type:
            %    constant <= variable
            bool = yop.box_constraint.isa_type2(relation) && ...
                (isequal(relation.relation, @lt) || isequal(relation.relation, @le));
        end
        
        function bool = isa_equality(relation)
            % Tests if a box constraint is an upper bound that is:
            % test if the object is one of the following:
            %   v >= c
            %   c <= v
            bool = yop.box_constraint.isa_equality_type1(relation) || ...
                yop.box_constraint.isa_equality_type2(relation);
        end
        
        function bool = isa_equality_type1(relation)
            % test if it is a box constraint of the following type:
            %   variable == constant
            bool = yop.box_constraint.isa_type1(relation) && ...
                isequal(relation.relation, @eq);
        end
        
        function bool = isa_equality_type2(relation)
            % test if it is a box constraint of the following type:
            %    constant == variable
            bool = yop.box_constraint.isa_type2(relation) && ...
                isequal(relation.relation, @eq);
        end
        
        function bool = isa_type1(relation)
            % test if it is a box constraint of the following type:
            %   varaible [relation] constant.
            %   example upper bound: v <= c
            %   example lower bound: v >= c
            bool = yop.box_constraint.isa_box(relation) && ...
                isa_variable(relation.left) && ...
                isa(relation.right, 'yop.constant');
        end
        
        function bool = isa_type2(relation)
            % test if it is a box constraint of the following type:
            %   constant [relation] varaible.
            %   example lower bound: c <= v
            %   example upper bound: c >= v
            bool = yop.box_constraint.isa_box(relation) && ...
                isa(relation.left, 'yop.constant') && ...
                isa_variable(relation.right);
        end
        
        function bd = get_bound(relation)
            if yop.box_constraint.isa_type1(relation)
                bd = relation.right;
                
            elseif yop.box_constraint.isa_type2(relation)
                bd = relation.left;
                
            else
                yop.assert(false);
                
            end
        end
        
        function indices = get_indices(relation)
            % Follows the impletementation in yop.subs_operation
            if yop.box_constraint.isa_type1(relation)
                indices = relation.left.get_indices();
                
            elseif yop.box_constraint.isa_type2(relation)
                indices = relation.right.get_indices();
                
            else
                yop.assert(false);
                
            end
        end
                
    end
        
end