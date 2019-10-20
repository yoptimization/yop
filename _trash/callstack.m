classdef callstack < handle
    properties        
        stack = {};
        levels = 0;
    end
    methods
        function obj = callstack()
        end     
        
        function elements = get(obj, level)
            elements = obj.stack{level};
        end
        
        function obj = add(obj, element)
            obj.stack{obj.levels+1} = {element};
            obj.levels = obj.levels + 1;
        end
        
        function merged_stack = merge(stack_a, stack_b) 
            merged_stack = yop.callstack();
            if stack_a.levels >= stack_b.levels
                merged_stack.stack = stack_a.stack;
                merged_stack.levels = stack_a.levels;
                merge_levels = stack_b.levels;
            else
                merged_stack.stack = stack_b.stack;
                merged_stack.levels = stack_b.levels;
                merge_levels = stack_a.levels;
            end               
            
            for k=1:merge_levels                
                merged_stack.stack{k} = [stack_a.stack{k}, stack_b.stack{k}];
            end
            
        end
    end
end