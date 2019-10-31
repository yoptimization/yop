classdef node_list < yop.list
    
    methods
        function obj = node_list()
        end
        
        function split_list = split(obj)
            split_list = yop.node_list();
            for k=1:length(obj)
                split_list.concatenate(obj.object(k).split);
            end
        end
        
        function gf = general_form(obj)
            gf = yop.node_list();
            for k=1:length(obj)
                gf.add(obj.object(k).general_form);
            end
        end
        
        function nf = nlp_form(obj)
            nf = yop.node_list();
            for k=1:length(obj)
                nf.add(obj.object(k).nlp_form);
            end
        end
        
        function l = left(obj)
            l = yop.node_list();
            for k=1:length(obj)
                l.add(obj.object(k).left);
            end
        end
        
        function value = evaluate(obj)
            value = [];
            for k=1:length(obj)
                value = [value; obj.object(k).evaluate];
            end
        end
        
    end
    
end