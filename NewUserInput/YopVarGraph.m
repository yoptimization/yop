classdef (InferiorClasses = {?YopVar, ?YopVarTimed, ?YopIntegral}) YopVarGraph < handle & matlab.mixin.Copyable
    
    properties
        Operation
        Argument
    end
    
    methods % Class
        function obj = YopVarGraph(operation, varargin)
            obj.Operation = operation;
            obj.Argument = YopVarGraph.convert(varargin);            
        end       
        
        function bool = isaRelation(obj)
            bool = YopVarGraph.isRelationOperation(obj.Operation);
        end        
        
        function bool = isaExpression(obj)
            bool = true;
            operations = obj.getOperations;
            for k=1:length(operations)
               bool = bool & ~YopVarGraph.isRelationOperation(operations{k});
            end
        end
        
        function bool = isaVariable(obj)
            bool = false;
        end
        
        function bool = isnumeric(obj)
            bool = false;
        end
        
        function l = lhs(obj)
            l = obj.Argument{1};
        end
        
        function r = rhs(obj)
            r = obj.Argument{2};
        end
        
        function disp(obj)
            for k=1:length(obj)
                disp(obj(k).evaluate);
            end
        end
        
        function display(obj)
            % Bygga något eget rekursivt? om funktionsnamnet är förknippat
            % med en operation med egen symbol byt till symbolen annars
            % skriv ut namnet.
            [r, c] = size(obj);
            elements = [];
            for k=1:length(obj)
                if r > c
                    elements = [elements; obj(k).evaluate];
                else
                    elements = [elements, obj(k).evaluate];
                end
            end
            eval([inputname(1) '= elements']);
        end
    end
    
    methods % YopVar/-Graph Interface        
        function bool = areEqual(x, y)
            bool = false;
        end
        
        function result = evaluate(obj)
            argument = cellfun(@(arg) evaluate(arg), obj.Argument, ...
                'UniformOutput', false);
            result = evaluate(obj.Operation( argument{:} ));
        end
        
        function n = numberOfNodes(obj)
            n = 1 + sum( cellfun(@numberOfNodes, obj.Argument) );
        end
        
        function operations = getOperations(obj)
            operations = {obj.Operation};
            for k=1:length(obj.Argument)
                operations = [operations(:); getOperations(obj.Argument{k})];
            end
        end
        
        function nargs = numberOfInputArguments(obj)
            nargs = 0;
            for k=1:length(obj.Argument)
                nargs = nargs + numberOfInputArguments(obj.Argument{k});
            end
        end
        
        function args = getInputArguments(obj)
            args = {};
            for k=1:length(obj.Argument)
                args = [args(:); getInputArguments(obj.Argument{k})];
            end
        end
    end
    
    methods % Math
        function z = plus(x, y)
            z = YopVarGraph(@plus, x, y);
        end
        
        function z = minus(x, y)
            z = YopVarGraph(@minus, x, y);
        end
        
        function y = uplus(x)
            y = YopVarGraph(@uplus, x);            
        end
        
        function y = uminus(x)
            y = YopVarGraph(@uminus, x);
        end
        
        function z = times(x, y)
            z = YopVarGraph(@times, x, y);
        end
        
        function z = mtimes(x, y)
            z = YopVarGraph(@mtimes, x, y);
        end
        
        function z = rdivide(x, y)
            z = YopVarGraph(@rdivide, x, y);
        end
        
        function z = ldivide(x, y)
            z = YopVarGraph(@ldivide, x, y);
        end        
        
        function z = power(x, y)
           z = YopVarGraph(@power, x, y);
        end
        
        function z = mpower(x, y)
           z = YopVarGraph(@mpower, x, y);
        end    
        
        function r = lt(lhs, rhs)
            r = YopVarGraph(@lt, lhs, rhs);
        end
        
        function r = gt(lhs, rhs)
            r = YopVarGraph(@gt, lhs, rhs);
        end
        
        function r = le(lhs, rhs)
            r = YopVarGraph(@le, lhs, rhs);
        end
        
        function r = ge(lhs, rhs)
            r = YopVarGraph(@ge, lhs, rhs);
        end
        
        function r = ne(lhs, rhs)
            r = YopVarGraph(@ne, lhs, rhs);
        end
        
        function r = eq(lhs, rhs)
            r = YopVarGraph(@eq, lhs, rhs);
        end
        
        function b = and(lhs, rhs)
            b = YopVarGraph(@and, lhs, rhs);
        end
        
        function b = or(lhs, rhs)
            b = YopVarGraph(@or, lhs, rhs);
        end
        
        function b = not(lhs, rhs)
            b = YopVarGraph(@not, lhs, rhs);
        end            
    end
    
    methods % Graph interpretation and modification                
        function bool = isaBox(obj)
            bool = xor(isaVariable(obj.lhs), isaVariable(obj.rhs)) && ...
                xor(isnumeric(obj.lhs), isnumeric(obj.rhs));
        end
        
        function bool = isaEquality(obj)
            bool = isequal(obj.Operation, @eq);
        end
        
        function bool = isaUpperBound(obj)
            bool = (...
                (obj.rhs.isnumeric && isequal(obj.Operation, @lt)) || ...
                (obj.rhs.isnumeric && isequal(obj.Operation, @le)) || ...
                (obj.lhs.isnumeric && isequal(obj.Operation, @gt)) || ...
                (obj.lhs.isnumeric && isequal(obj.Operation, @ge)) ...
                ) && obj.isaBox;      
        end
        
        function bool = isaLowerBound(obj)
            bool = (...
                (obj.lhs.isnumeric && isequal(obj.Operation, @lt)) || ...
                (obj.lhs.isnumeric && isequal(obj.Operation, @le)) || ...
                (obj.rhs.isnumeric && isequal(obj.Operation, @gt)) || ...
                (obj.rhs.isnumeric && isequal(obj.Operation, @ge)) ...
                ) && obj.isaBox;
        end
        
        function bd = getBound(obj)
            if obj.isaEquality
            end
        end
        
        function ub = getUpperBound(obj)
            ub = [];
            if obj.isaUpperBound && ...
                    (isequal(obj.Operation, @gt) || isequal(obj.Operation, @ge))
                ub = obj.lhs;
                
            elseif obj.isaUpperBound && ...
                    (isequal(obj.Operation, @lt) || isequal(obj.Operation, @le))
                ub = obj.rhs;
                
            end
        end
        
        function ub = getLowerBound(obj)
            ub = [];
            if obj.isaLowerBound && ...
                    (isequal(obj.Operation, @gt) || isequal(obj.Operation, @ge))
                ub = obj.rhs;
                
            elseif obj.isaLowerBound && ...
                    (isequal(obj.Operation, @lt) || isequal(obj.Operation, @le))
                ub = obj.lhs;
                
            end
        end
        
        function l = leftmostExpression(obj)
            if obj.isaExpression
                l = obj;                
            else
                l = leftmostExpression(obj.lhs);
            end            
        end
        
        function r = rightmostExpression(obj)
            if obj.isaExpression
                r = obj;
            else
                r = rightmostExpression(obj.rhs);                
            end
        end
        
        function graph = unnestRelations(obj)
            % Interprets graph as a constraint and unnest relations in the
            % graph from left to right. May brake down if graph is not a 
            % valid constraint.
            % I.e. -1 <= f(x) <= 1 turns into:
            %  -1 <= f(x)
            %  f(x) <= 1
            
            if length(obj) > 1
                graph = [];
                for k=1:length(obj)
                    graph = [graph; obj(k).unnestRelations];
                end
                
            elseif obj.lhs.isaExpression && obj.rhs.isaExpression
                graph = obj;
                
            elseif obj.lhs.isaExpression && obj.rhs.isaRelation
                graph = [ ...
                    YopVarGraph(obj.Operation, obj.lhs, leftmostExpression(obj.rhs)); ...
                    unnestRelations(obj.rhs) ...
                    ];
                
            elseif obj.lhs.isaRelation && obj.rhs.isaExpression
                graph = [ ...
                    unnestRelations(obj.lhs); ...
                    YopVarGraph(obj.Operation, rightmostExpression(obj.lhs), obj.rhs) ...                    
                    ];
                
            elseif obj.lhs.isaRelation && obj.rhs.isaRelation
                graph = [ ...
                    unnestRelations(obj.lhs); ...
                    YopVarGraph(obj.Operation, rightmostExpression(obj.lhs), leftmostExpression(obj.rhs)); ...
                    unnestRelations(obj.rhs) ...
                    ];                
            end   
            
        end
        
        function constraint = setToNlpForm(obj)
            % Sets an unnested graph to the following form.
            % h(x) <= 0
            % g(x) == 0
            % Presumes the graph has been unnested
            
            if length(obj) > 1
                constraint = [];
                for k=1:length(obj)
                    constraint = [constraint; obj(k).setToNlpForm];
                end
            
            elseif isequal(obj.Operation, @lt) || isequal(obj.Operation, @le)
                constraint = YopVarGraph( ...
                    @le, ...
                    obj.lhs - obj.rhs, ...
                    zeros( size(obj.lhs.evaluate) ) ...
                    );
                
            elseif isequal(obj.Operation, @gt) || isequal(obj.Operation, @ge)
                constraint = YopVarGraph( ...
                    @le, ...
                    obj.rhs - obj.lhs, ...
                    zeros( size(obj.lhs.evaluate) ) ...
                    );                
                
            elseif isequal(obj.Operation, @eq)
                constraint = YopVarGraph( ...
                    @eq, ...
                    obj.lhs - obj.rhs, ...
                    zeros( size(obj.lhs.evaluate) ) ...
                    );                
            end
        end
    end
    
    methods (Access=protected)
        function cpObj = copyElement(obj)
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            cpObj.Argument = cell(size(obj.Argument));
            for k=1:length(obj.Argument)
                cpObj.Argument{k} = copy(obj.Argument{k});
            end
        end
    end
    
    methods (Static)
        function args = convert(args)
            for k=1:length(args)
                if ~isa(args{k}, 'YopVar') && ~isa(args{k}, 'YopVarGraph')
                    args{k} = YopVar(args{k});
                end
            end
        end
        
        function bool = isRelationOperation(operation)
            bool = ...
                isequal(operation, @lt) || ...
                isequal(operation, @gt) || ...
                isequal(operation, @le) || ...
                isequal(operation, @ge) || ...
                isequal(operation, @ne) || ...
                isequal(operation, @eq);
        end
    end
end