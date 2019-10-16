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
        
        function objects = get_object(obj)            
            objects = cell(size(obj));
            for k=1:size(obj,2)
                objects{k} = obj(k).object;
            end
        end        
    end
end