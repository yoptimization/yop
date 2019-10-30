classdef nonlinear_programming < yop.relation
   
    methods (Static)
        
        function [box, equality, inequality] = classify(varargin)
            % Classify the relations in varargin into box constraints,
            % equality constraints, and inequality constraints.
            
            % Store all constraints in a list
            constraints = yop.node_list().add_array(varargin);
            
            % Separate box and nonlinear (could be linear, but not box) 
            % constraints.
            [box, nl_con] = constraints.split.sort("first", ...
                @yop.nonlinear_programming.isa_box, ...
                @isa_valid_relation ...
                );
            
            % Put the nonlinear constraints on first general form i.e.
            % f(x) [relation] 0 and then on nlp form: g(x)==0, h(x)<=0.
            [equality, inequality] = nl_con.general_form.nlp_form.sort("first", ...
                @(x)isequal(x.operation, @eq), ...
                @(x)isequal(x.operation, @le));
            
        end
        
        function bool = isa_box(relation)
            % Tests if the following structure (r=relation, e=expression):
            %      r
            %     / \
            %    e1 e2
            % is a box constraint.
            % Notice that it doesn't test if the strucure is correct.
            bool = relation.left.isa_symbol && isa(relation.right, 'yop.constant') || ...
                isa(relation.left, 'yop.constant') && relation.right.isa_symbol;
        end
        
        function bool = isa_upper_bound(relation)
            % Tests if a box constraint is an upper bound that is:
            % test if the object is one of the following:
            %   v <= c
            %   c >= v
            bool = yop.nonlinear_programming.isa_upper_type1(relation) || ...
                yop.nonlinear_programming.isa_upper_type2(relation);
        end
        
        function bool = isa_upper_type1(relation)
            % test if it is a box constraint of the following type:
            %   variable <= constant
            bool = yop.nonlinear_programming.isa_type1(relation) && ...
                (isequal(relation.operation, @lt) || isequal(relation.operation, @le));
        end
        
        function bool = isa_upper_type2(relation)
            % test if it is a box constraint of the following type:
            %    constant >= variable
            bool = yop.nonlinear_programming.isa_type2(relation) && ...
                (isequal(relation.operation, @gt) || isequal(relation.operation, @ge));
        end
        
        function bool = isa_lower_bound(relation)
            % Tests if a box constraint is an upper bound that is:
            % test if the object is one of the following:
            %   v >= c
            %   c <= v
            bool = yop.nonlinear_programming.isa_lower_type1(relation) || ...
                yop.nonlinear_programming.isa_lower_type2(relation);
        end
        
        function bool = isa_lower_type1(relation)
            % test if it is a box constraint of the following type:
            %   variable >= constant
            bool = yop.nonlinear_programming.isa_type1(relation) && ...
                (isequal(relation.operation, @gt) || isequal(relation.operation, @ge));
        end
        
        function bool = isa_lower_type2(relation)
            % test if it is a box constraint of the following type:
            %    constant <= variable
            bool = yop.nonlinear_programming.isa_type2(relation) && ...
                (isequal(relation.operation, @lt) || isequal(relation.operation, @le));
        end
        
        function bool = isa_equality(relation)
            % Tests if a box constraint is an upper bound that is:
            % test if the object is one of the following:
            %   v >= c
            %   c <= v
            bool = yop.nonlinear_programming.isa_equality_type1(relation) || ...
                yop.nonlinear_programming.isa_equality_type2(relation);
        end
        
        function bool = isa_equality_type1(relation)
            % test if it is a box constraint of the following type:
            %   variable == constant
            bool = yop.nonlinear_programming.isa_type1(relation) && ...
                isequal(relation.operation, @eq);
        end
        
        function bool = isa_equality_type2(relation)
            % test if it is a box constraint of the following type:
            %    constant == variable
            bool = yop.nonlinear_programming.isa_type2(relation) && ...
                isequal(relation.operation, @eq);
        end
        
        function bool = isa_type1(relation)
            % test if it is a box constraint of the following type:
            %   varaible [relation] constant.
            %   example upper bound: v <= c
            %   example lower bound: v >= c
            bool = yop.nonlinear_programming.isa_box(relation) && ...
                isa_symbol(relation.left) && ...
                isa(relation.right, 'yop.constant');
        end
        
        function bool = isa_type2(relation)
            % test if it is a box constraint of the following type:
            %   constant [relation] varaible.
            %   example lower bound: c <= v
            %   example upper bound: c >= v
            bool = yop.nonlinear_programming.isa_box(relation) && ...
                isa(relation.left, 'yop.constant') && ...
                isa_symbol(relation.right);
        end
        
        function bd = get_bound(relation)
            if yop.nonlinear_programming.isa_type1(relation)
                bd = relation.right;
                
            elseif yop.nonlinear_programming.isa_type2(relation)
                bd = relation.left;
                
            else
                yop.assert(false);
                
            end
        end
        
        function indices = get_indices(relation)
            % Follows the impletementation in yop.subs_operation
            if yop.nonlinear_programming.isa_type1(relation)
                indices = relation.left.get_indices();
                
            elseif yop.nonlinear_programming.isa_type2(relation)
                indices = relation.right.get_indices();
                
            else
                yop.assert(false);
                
            end
        end
                
    end
        
end