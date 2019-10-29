classdef keywords < handle
    properties
        variable
        default_name_constant
        default_name_variable
        default_name_parameter
        default_name_lhs
        default_name_rhs
    end
    
    methods
        
        function obj = keywords()
            % Ska påminna om options beträffande att spara etc.
            persistent singleton
            if isempty(singleton)
                singleton = obj;
                singleton.set_default();
            else
                obj = singleton;
            end
        end
        
        function obj = set_default(obj)
            obj.variable = 'variable';
            obj.default_name_constant = 'c';
            obj.default_name_variable = 'v';
            obj.default_name_parameter = 'p';
            obj.default_name_lhs = 'lhs';
            obj.default_name_rhs = 'rhs';
        end
            
    end
end