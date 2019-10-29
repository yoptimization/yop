classdef nlp < handle
    properties
        variable
        upper_bound
        lower_bound
        objective
        constraints
        equality_constraints
        inequality_constraints
    end
    methods
        function obj = nlp(varargin)
            ip = inputParser;
            ip.FunctionName = 'nlp';
            ip.PartialMatching = false;
            ip.KeepUnmatched = false;
            ip.CaseSensitive = true;
            
            ip.addParameter(yop.keywords().variable, []);
            ip.parse(varargin{:})
            
            yop.assert(~isempty(ip.Results.variable), ...
                yop.messages.optimization_variable_missing);
            yop.assert(size(ip.Results.variable,2)==1, ...
                yop.messages.optimization_column_vector);
            
            obj.variable = ip.Results.(yop.keywords().variable);
            obj.upper_bound =  yop.node('ub', size(x));
            obj.lower_bound = yop.node('lb', size(x));
            obj.upper_bound.value =  inf(size(x));
            obj.lower_bound.value = -inf(size(x));
        end
        
        function obj = minimize(obj, f)
            obj.objective = f;
        end
        
        function obj = maximize(obj, f)
            obj.objective = -f;
        end
        
        function obj = subject_to(obj, varargin)
            obj.constraints = yop.node_list();
            for k=1:length(varargin)
                obj.constraints.add(varargin{k});
            end
        end
        
        function obj = solve(obj)
            [box, nonlin] = obj.constraints.split.sort(@isa_box, @(x) ~isa_box(x));
            obj.parse_box_constraints(box);
            [eq, neq] = nonlin.general_form.nlp_form.sort( ...
                @(x)isequal(x.relation, @eq), ...
                @(x)isequal(x.relation, @le) ...
                );
            
        end
        
        function obj = parse_box_constraints(obj, box)
            % Gör för ett enda box constraint och lägg loopen där
            % bivillkoren tas emot.
            for k=1:length(box)
                
                if box.object(k).isa_upper_type1
                    obj.upper_bound(box.object(k).left.get_indices) = ...
                        box.object(k).right;
                    
                elseif box.object(k).isa_upper_type2
                    obj.upper_bound(box.object(k).right.get_indices) = ...
                        box.object(k).left;
                    
                elseif box.object(k).isa_lower_type1
                    obj.lower_bound(box.object(k).left.get_indices) = ...
                        box.object(k).right;
                    
                elseif box.object(k).isa_lower_type2
                    obj.lower_bound(box.object(k).right.get_indices) = ...
                        box.object(k).left;
                    
                elseif box.object(k).isa_equality_type1
                    obj.upper_bound(box.object(k).left.get_indices) = ...
                        box.object(k).right;
                    obj.lower_bound(box.object(k).left.get_indices) = ...
                        box.object(k).right;
                    
                elseif box.object(k).isa_equality_type2
                    obj.upper_bound(box.object(k).right.get_indices) = ...
                        box.object(k).left;
                    obj.lower_bound(box.object(k).right.get_indices) = ...
                        box.object(k).left;
                    
                end
            end
        end
        
    end
end