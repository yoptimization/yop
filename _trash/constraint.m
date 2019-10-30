classdef constraint < yop.relation
    methods (Static)
        function [box, equality, inequality] = classify(varargin)
            % Classify the relations in varargin into box constraints,
            % equality constraints, and inequality constraints.
            
            % Store all constraints in a list
            constraints = yop.node_list().add_array(varargin);
            
            % Separate box and nonlinear (could be linear, but not box) 
            % constraints.
            [box, nl_con] = constraints.split.sort( ...
                @yop.box_constraint.isa_box, ...
                @(x) ~yop.box_constraint.isa_box(x) ...
                );
            
            % Put the nonlinear constraints on first general form i.e.
            % f(x) [relation] 0 and then on nlp form: g(x)==0, h(x)<=0.
            [equality, inequality] = nl_con.general_form.nlp_form.sort( ...
                @(x)isequal(x.operation, @eq), ...
                @(x)isequal(x.operation, @le));
            
        end
    end
end