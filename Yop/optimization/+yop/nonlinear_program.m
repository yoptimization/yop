classdef nonlinear_program < handle
    properties
        variable
        upper_bound
        lower_bound
        objective
        equality_constraints
        inequality_constraints
    end
    methods
        function obj = nonlinear_program(varargin)
            ip = inputParser;
            ip.FunctionName = 'nonlinear_program';
            ip.PartialMatching = false;
            ip.KeepUnmatched = false;
            ip.CaseSensitive = true;
            
            ip.addParameter(yop.keywords().variable, []);
            ip.parse(varargin{:})
            
            yop.assert(~isempty(ip.Results.variable), ...
                yop.messages.optimization_variable_missing);
            yop.assert(size(ip.Results.variable,2)==1, ...
                yop.messages.optimization_not_column_vector);
            
            obj.variable = ip.Results.(yop.keywords().variable);
            obj.upper_bound = yop.node('ub', size(obj.variable));
            obj.lower_bound = yop.node('lb', size(obj.variable));
            obj.upper_bound.value =  inf(size(obj.variable));
            obj.lower_bound.value = -inf(size(obj.variable));
        end
        
        function present(obj)
            % Alt överlagra disp/display.
        end
        
        function obj = minimize(obj, f)
            obj.objective = f;
        end
        
        function obj = maximize(obj, f)
            obj.objective = -f;
        end
        
        function obj = subject_to(obj, varargin)
            [box, eq, ieq] = yop.nonlinear_programming.classify(varargin{:});
            obj.add_box(box);
            
            if isempty(eq.elements)
                obj.equality_constraints = yop.node('empty', [0,0]);
            else
                obj.equality_constraints = vertcat(eq.left.elements.object);
            end
            
            if isempty(ieq.elements)
                obj.inequality_constraints = yop.node('empty', [0,0]);
            else
                obj.inequality_constraints = vertcat(ieq.left.elements.object);
            end
        end
        
        function obj = add_box(obj, box)
            for k=1:length(box)
                index = yop.nonlinear_programming.get_indices(box.object(k));
                bd = yop.nonlinear_programming.get_bound(box.object(k));
                
                if yop.nonlinear_programming.isa_upper_bound(box.object(k))
                    obj.upper_bound(index) = bd;
                    
                elseif yop.nonlinear_programming.isa_lower_bound(box.object(k))
                    obj.lower_bound(index) = bd;
                    
                elseif yop.nonlinear_programming.isa_equality(box.object(k))    
                    obj.upper_bound(index) = bd;
                    obj.lower_bound(index) = bd;
                end
            end
        end
        
        function results = solve(obj, x0)
            ip = inputParser;
            ip.FunctionName = 'nonlinear_program.solve';
            ip.PartialMatching = false;
            ip.KeepUnmatched = false;
            ip.CaseSensitive = true;
            
            nlp = struct;
            nlp.x = obj.variable.evaluate;
            nlp.f = obj.objective.evaluate;
            nlp.g = [...
                obj.equality_constraints.evaluate; ...
                obj.inequality_constraints.evaluate ...
                ];
            
            yoptimizer = casadi.nlpsol('yoptimizer', 'ipopt', nlp);
            res = yoptimizer( ...
                'x0', x0, ...
                'ubx', obj.upper_bound.evaluate, ...
                'lbx', obj.lower_bound.evaluate, ...
                'ubg', [zeros(size(obj.equality_constraints)); zeros(size(obj.inequality_constraints))], ...
                'lbg', [zeros(size(obj.equality_constraints)); -inf(size(obj.inequality_constraints))]);
            results = full(res.x);
            
        end
        
    end
end