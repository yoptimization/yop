classdef variable < yop.node
    
    methods
        
        function obj = variable(name, rows, columns)
            if nargin == 0
                name = 'v';
                rows = 1;
                columns = 1;
                
            elseif nargin == 1
                rows = 1;
                columns = 1;
                
            elseif nargin == 2
                columns = 1;
                
            end
            obj@yop.node(name, rows, columns);
            obj.value = yop.variable.symbol(name, rows, columns);
        end
        
        function indices = get_indices(obj)
            % Returns the indices in the vector variable
            % Observe that it doesn't test if it is a vector valued
            % variable or scalar.
            indices = 1:length(obj);
        end
        
    end
    
    methods (Static)
        
        function v = symbol(name, rows, columns)
            if yop.options.get_symbolics == yop.options.name_symbolic_math
                
                if rows==1 && columns==1
                    v = sym(name, 'real');
                else
                    v = sym(name, [rows, columns], 'real');
                end
                
            elseif yop.options.get_symbolics == yop.options.name_casadi
                v = [];
                for c=1:columns
                    v_r = [];
                    for r=1:rows
                        name_rc = [name '_(' num2str(r) ',' num2str(c) ')'];
                        v_rc = casadi.MX.sym(name_rc, 1, 1);
                        v_r = [v_r; v_rc];
                    end
                    v = [v, v_r];
                end
            end
        end
        
    end
end