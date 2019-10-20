classdef list < handle
    
    properties
        elem
    end
    
    methods
        
        function obj = list()
        end
        
        function obj = add(obj, e)
            new_elem = yop.list_elem(e);
            if isempty(obj.elem)
                obj.elem = new_elem;
            else
                obj.elem(end+1) = new_elem;
            end
        end
        
        function obj = remove(obj, e)
            for k=1:size(obj.elem, 2)
                if isequal(obj.elem(k).object, e)
                    obj.elem = obj.elem([1:k-1, k+1:size(obj.elem,2)]);
                    break
                end
            end
        end
        
        function bool = contains(obj, e)
            bool = false;
            for k=1:size(obj.elem, 2)
                if isequal(obj.elem(k).object, e)
                    bool = true;
                    break
                end
            end
        end             
        
    end
end