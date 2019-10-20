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
            
            if yop.options.get_symbolics == "symbolic_math"
                if rows==1 && columns==1
                    obj.value = sym(name);
                else
                    obj.value = sym(name, [rows, columns]);
                end
                
            elseif yop.options.get_symbolics == "casadi"
                obj.value = casadi.MX.sym(name, rows, columns);
                
            end
        end
        
        function obj = forward(obj)
        end
        
    end
end