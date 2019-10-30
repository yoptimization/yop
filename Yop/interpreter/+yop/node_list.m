classdef node_list < yop.list
    
    methods
        function obj = node_list()
        end
        
        function varargout = sort(obj, mode, varargin)
            % [box, rest] = sort(@isa_box, @is_valid);
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