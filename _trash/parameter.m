classdef parameter < yop.variable
    
    methods
        function obj = parameter(name, rows, columns)
            if nargin == 0
                name = 'p';
                rows = 1;
                columns = 1;
                
            elseif nargin == 1
                rows = 1;
                columns = 1;
                
            elseif nargin == 2
                columns = 1;
                
            end
            obj@yop.variable(name, rows, columns);
        end
    end
    
end