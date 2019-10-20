classdef node_listener_list_elem < yop.list_elem 
    
    properties
        listener
    end
    
    methods
        
        function obj = node_listener_list_elem(object, listener)
            obj@yop.list_elem(object)
            obj.listener = listener;
        end
        
    end
    
end