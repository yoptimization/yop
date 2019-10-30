classdef constraint < yop.relation
    methods (Static)
        function [box, equality, inequality] = classify(varargin)
            % Classify the relations in varargin into box constraints,
            % equality constraints, and inequality constraints.
            
            % Store all constraints in a list
            constraints = yop.node_list();
            for k=1:length(varargin)
                constraints.add(varargin{k});
            end
            
            % Separate box and nonlinear (could be linear, but not box) 
            % constraints.
            [box, nl_con] = constraints.split.sort( ...
                @yop.box_constraint.isa_box, ...
                @(x) ~yop.box_constraint.isa_box(x) ...
                );
            
            % Put the nonlinear constraints on first general form i.e.
            % f(x) [relation] 0 and then on nlp form: g(x)==0, h(x)<=0.
            [equality, inequality] = nl_con.general_form.nlp_form.sort( ...
                @(x)isequal(x.relation, @eq), ...
                @(x)isequal(x.relation, @le));
            
        end
    end
end