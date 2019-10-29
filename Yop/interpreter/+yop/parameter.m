classdef parameter < yop.variable
    
    methods
        function obj = parameter(name, size)
            if nargin == 0
                name = yop.keywords().default_name_parameter;
                size = [1, 1];
                
            elseif nargin == 1
                size = [1, 1];
                
            end
            obj@yop.variable(name, size);
        end
    end
    
end