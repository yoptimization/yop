classdef node_listener_list < yop.list

    methods
        function obj = node_listener_list()
        end
        
        function obj = add(obj, e, listener)
            new_elem = yop.node_listener_list_elem(e, listener);
            if isempty(obj.elements)
                obj.elements = new_elem;
            else
                obj.elements(end+1) = new_elem;
            end
        end
        
        function obj = remove(obj, e)
            for k=1:size(obj.elem, 2)
                if isequal(obj.elements(k).object, e)
                    delete(obj.elements(k).listener);
                    obj.elem = obj.elements([1:k-1, k+1:size(obj.elements,2)]);
                    break
                end
            end
        end
        
    end
end