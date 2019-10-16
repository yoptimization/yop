classdef stack_element < handle
    properties
        element        
    end
    methods
        function obj = stack_element(element)
            obj.element = element;
        end
        
        function val = value(obj)
            val = obj.element.value;
        end
    end
end