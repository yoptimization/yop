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
        end
        
        function value = forward(obj)
            value = obj.value;
            obj.stored_value = true;
        end
    end
end