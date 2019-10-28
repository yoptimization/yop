classdef constant < yop.node
    
    methods
        
        function obj = constant(name, rows, columns)
            if nargin == 0
                name = 'c';
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
        
    end
end