classdef subs_operation < yop.operation
    methods
        function obj = subs_operation(name, rows, columns, operation)
            obj@yop.operation(name, rows, columns, operation);
        end
    end
end