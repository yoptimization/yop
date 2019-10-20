classdef pointer < handle
    properties
        object
    end
    methods
        
        function obj = pointer(object)
            if nargin == 1
                obj.object = object;
            end
        end
        
        function bool = contains(obj, pointer)
            bool = false;
            for k=1:length(obj)
                if isequal(obj(k), pointer)
                    bool = true;
                    break;
                end
            end
        end
        
        function obj = add(obj, pointer)
        end
        
        function obj = remove(obj, pointer)
        end
        
    end
end