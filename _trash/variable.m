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
            obj@yop.node();
            obj.init(name, rows, columns)
            
            % This assignment should not be done here. It would inflict on
            % the possibilty of creating yop with yop.
            obj.value = yop.variable.symbol(name, rows, columns);
        end
        
    end
    
    methods (Static)
        
        function v = symbol(name, rows, columns)  
            % Bör bytas mot en metod. set_symbol / make_symbolic.
            if yop.options.get_symbolics == yop.options.name_symbolic_math
                
                if rows==1 && columns==1
                    v = sym(name, 'real');
                else
                    v = sym(name, [rows, columns], 'real');
                end
                
            elseif yop.options.get_symbolics == yop.options.name_casadi
                v = casadi.MX.sym(name, rows, columns);
                
            end
        end
        
    end
end