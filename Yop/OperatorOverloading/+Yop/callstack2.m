classdef callstack2 < handle
    properties
        stack
    end
    methods
        
        function obj = callstack2()
        end
        
        function obj = init(obj, node)
            obj.stack = node.pointer;
        end
        
        function obj = add_node(obj, node)
            % 0) högre eval än vad som finns?
            % 1) finns den?
            % 2) får den plats?
            % 3) gör plats
            
            if node.evaluation_level > size(obj.stack,2)
                obj.stack(1, node.evaluation_level) = node.pointer;
                
            else
                
                
                
                
                unique = true;               
                for k=1:size(obj.stack,1)
                    if obj.stack(k,node.evaluation_level) == node.pointer
                        unique = false;
                        break;
                        
                    elseif isempty(obj.stack(k,node.evaluation_level).value)
                        break;
                        
                    end
                    empty_position = k+1;
                end
                
                if unique && empty_position
                    obj.stack(empty_position,node.evaluation_level) = node.pointer;
                    
                elseif unique
                    obj.stack(end+1, node.evaluation_level) = node.pointer;
                    
                end
            end
        end
        
        function obj = add_elem(obj, elem)
            
        end
        
        function new = merge(a, b)
            new = yop.callstack2;
            if size(a.stack,2) >= size(b.stack,2)
                new.stack = a.stack;
                merged = b;
                
            else
                new.stack = b.stack;
                merged = a;
                
            end
            
            for l=1:size(merged,2)
%                 elems = 
            end
            
            
        end
        
    end
end

% classdef callstack2 < handle
%     properties
%         nodes % a array of pointers to pointers of the nodes
%         allocation_map % Last row used for storing in each level
%         ids % Vector containing ids
%         id_row
%         id_col
%     end
%     methods
%
%         function obj = callstack2()
%         end
%
%         function obj = init(obj, node)
%             new_elem = yop.gpo();
%             new_elem.value = node;
%             obj.nodes = new_elem;
%             obj.allocation_map = 1;
%             obj.ids = node.id;
%             obj.id_row(node.id) = 1;
%             obj.id_col(node.id) = 1;
%         end
%
%         function obj = add_node(obj, node)
%             if isempty(yop.setdiff(obj.ids, node.id)) %~ismember(obj.ids, node.id)
%                 new_elem = yop.gpo;
%                 new_elem.value = node;
%
%                 if node.evaluation_level > size(obj.nodes, 2)
%                     obj.allocation_map(node.evaluation_level) = 0;
%                 end
%
%                 row = obj.allocation_map(node.evaluation_level)+1;
%                 obj.nodes(row, node.evaluation_level) = new_elem;
%                 obj.allocation_map(node.evaluation_level) = row;
%                 obj.ids(end+1) = node.id;
%                 obj.id_row(node.id) = row;
%                 obj.id_col(node.id) = node.evaluation_level;
%             end
%         end
%
%         function obj = add_elem(obj, elem)
%             if isempty(yop.setdiff(obj.ids, elem.value.id))%~ismember(obj.ids, elem.value.id)
%
%                 if elem.value.evaluation_level > size(obj.nodes, 2)
%                     obj.allocation_map(node.evaluation_level) = 0;
%                 end
%
%                 row = obj.allocation_map(elem.value.evaluation_level)+1;
%                 obj.nodes(row, elem.value.evaluation_level) = elem;
%                 obj.allocation_map(elem.value.evaluation_level) = row;
%                 obj.ids(end+1) = elem.value.id;
%                 obj.id_row(elem.value.id) = row;
%                 obj.id_col(elem.value.id) = elem.value.evaluation_level;
%             end
%         end
%
%         function m = merge(a, b)
%             m = yop.callstack2;
%             if size(a.ids,2) >= size(b.ids,2)
%                 m.nodes = a.nodes;
%                 m.allocation_map = a.allocation_map;
%                 m.ids = a.ids;
%                 m.id_row = a.id_row;
%                 m.id_col = a.id_col;
%                 merged = b;
%
%             else
%                 m.nodes = b.nodes;
%                 m.allocation_map = b.allocation_map;
%                 m.ids = b.ids;
%                 m.id_row = b.id_row;
%                 m.id_col = b.id_col;
%                 merged = a;
%
%             end
%
%             new_ids = yop.setdiff(merged.ids, m.ids);
%             for k=1:length(new_ids)
%                 row = merged.id_row(new_ids(k));
%                 col = merged.id_col(new_ids(k));
%                 elem = merged.nodes(row, col);
%                 m.add_elem(elem);
%             end
%
%
%         end
%
%     end
% end