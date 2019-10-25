classdef list < handle
    
    properties
        elements
    end
    
    methods
        
        function obj = list()
        end
        
        function o = object(obj, index)
            o = obj.elements(index).object;
        end
        
        function e = elem(obj, index)
            e = obj.elements(index);
        end
        
        function obj = concatenate(obj, list)
            obj.elements = [obj.elements, list.elements]; 
        end      
        
        function obj = add(obj, e)
            new_elem = yop.list_elem(e);
            if isempty(obj.elements)
                obj.elements = new_elem;
            else
                obj.elements(end+1) = new_elem;
            end
        end
        
        function obj = remove(obj, e)
            for k=1:size(obj.elements, 2)
                if isequal(obj.object(k), e)
                    obj.elements = obj.elements([1:k-1, k+1:size(obj.elements,2)]);
                    break
                end
            end
        end
        
        function bool = contains(obj, e)
            bool = false;
            for k=1:size(obj.elements, 2)
                if isequal(obj.object(k), e)
                    bool = true;
                    break
                end
            end
        end             
        
        function s = size(obj)
            s = size(obj.elements);
        end
        
        function l = length(obj)
            l = length(obj.elements);
        end
        
    end
end