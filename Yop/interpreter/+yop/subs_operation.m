classdef subs_operation < yop.operation
    methods
        function obj = subs_operation(name, size, operation)
            obj@yop.operation(name, size, operation);
        end
        
        function indices = get_indices(obj)
            % Parses the following structure:
            %         subs
            %         /  \
            %      subs   s
            %      /  \
            %     v   s
            % in order to find the indices in terms of the vector of class
            % yop.variable the the subs chain refers to
            
            if isa(obj.left, 'yop.variable')
                indices = obj.right.value.subs{1};
                
            elseif isa(obj.left, 'yop.subs_operation')
                tmp = obj.left.get_indices();
                indices = tmp(obj.right.value.subs{1});                
                
            else
                yop.assert(false);
                
            end
        end
    end
end