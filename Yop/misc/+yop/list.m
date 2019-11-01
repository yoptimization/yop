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
        
        function obj = add(obj, object)
            new_elem = yop.list_elem(object);
            if isempty(obj.elements)
                obj.elements = new_elem;
            else
                obj.elements(end+1) = new_elem;
            end
        end
        
        function obj = add_unique(obj, object)
            if ~obj.contains(object)
                obj.add(object);
            end
        end
        
        function obj = add_array(obj, cell_array)
            for k=1:length(cell_array)
                obj.add(cell_array{k});
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
        
        function bool = contains(obj, object)
            bool = false;
            for k=1:size(obj.elements, 2)
                if isequal(obj.object(k), object)
                    bool = true;
                    break
                end
            end
        end             
        
        function varargout = sort(obj, mode, varargin)
            varargout = cell(size(varargin));
            for n=1:length(varargout)
                varargout{n} = yop.node_list();
            end
            
            for k=1:length(obj)
                for c=1:length(varargin)
                    criteria = varargin{c};
                    if criteria(obj.object(k))
                        varargout{c}.add(obj.object(k));
                        if mode=="first"
                            break
                        end
                    end
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