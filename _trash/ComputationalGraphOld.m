classdef ComputationalGraph < Yop.MathOperations & Yop.VariableGraphInterface & Yop.DefaultChangingBehavior & matlab.mixin.Copyable
    
    properties
        Operation
        Argument
        Timepoint
        Index
    end
    
    methods % Class
        function obj = ComputationalGraph(operation, varargin)
            if nargin ~= 0                
                varargin = Yop.ComputationalGraph.convert(varargin);
                obj.Operation = operation;
                obj.Argument = varargin;
            end
        end
        
        function l = lhs(obj)
            l = obj.Argument{1};
        end
        
        function r = rhs(obj)
            r = obj.Argument{2};
        end
        
        function disp(obj, varargin)
            disp(evaluateComputation(obj));
            for k=1:length(varargin)
                disp(evaluateComputation(varargin{k}));
            end
        end
        
        function display(obj)
            variableName = inputname(1);
            if isempty(variableName)
                eval("evaluateComputation(obj)");
            else
                eval([inputname(1) '= evaluateComputation(obj)']);
            end
        end
    end
    
    methods % Graph interpretation and modification
        
        function bool = isaBox(obj)
            bool = xor(isaVariable(lhs(obj)), isaVariable(rhs(obj))) && ...
                xor(isaNumeric(lhs(obj)), isaNumeric(rhs(obj)));
        end
        
        function bool = isaEquality(obj)
            bool = isequal(obj.Operation, @eq);
        end
        
        function bool = isaUpperBound(obj)
            bool = (...
                (isaNumeric(rhs(obj)) && isequal(obj.Operation, @lt)) || ...
                (isaNumeric(rhs(obj)) && isequal(obj.Operation, @le)) || ...
                (isaNumeric(lhs(obj)) && isequal(obj.Operation, @gt)) || ...
                (isaNumeric(lhs(obj)) && isequal(obj.Operation, @ge)) ...
                ) && isaBox(obj);
        end
        
        function bool = isaLowerBound(obj)
            bool = (...
                (isaNumeric(lhs(obj)) && isequal(obj.Operation, @lt)) || ...
                (isaNumeric(lhs(obj)) && isequal(obj.Operation, @le)) || ...
                (isaNumeric(rhs(obj)) && isequal(obj.Operation, @gt)) || ...
                (isaNumeric(rhs(obj)) && isequal(obj.Operation, @ge)) ...
                ) && isaBox(obj);
        end
        
        function bd = getBound(obj)
            if isaEquality(obj)
            end
        end
        
        function ub = getUpperBound(obj)
            ub = [];
            if isaUpperBound(obj) && ...
                    (isequal(obj.Operation, @gt) || isequal(obj.Operation, @ge))
                ub = lhs(obj);
                
            elseif isaUpperBound(obj) && ...
                    (isequal(obj.Operation, @lt) || isequal(obj.Operation, @le))
                ub = rhs(obj);
                
            end
        end
        
        function lb = getLowerBound(obj)
            lb = [];
            if isaLowerBound(obj) && ...
                    (isequal(obj.Operation, @gt) || isequal(obj.Operation, @ge))
                lb = rhs(obj);
                
            elseif isaLowerBound(obj) && ...
                    (isequal(obj.Operation, @lt) || isequal(obj.Operation, @le))
                lb = lhs(obj);
                
            end
        end
        
        function node = findSubNodes(obj, criteria)
            if criteria(obj)
                node = obj;
            else
                node = {};
                for k=1:length(obj.Argument)
                    node = [node(:); {findSubNodes(obj.Argument{k}, criteria)}];
                end
            end
        end

        function graph = unnestRelations(obj)
            % Interprets graph as a constraint and unnest relations in the
            % graph from left to right. May brake down if graph is not a
            % valid constraint.
            % I.e. -1 <= f(x) <= 1 turns into:
            %  -1 <= f(x)
            %  f(x) <= 1            
         
            if graphIsaExpression(lhs(obj)) && graphIsaExpression(rhs(obj)) && nodeIsaRelation(obj)
                graph = {obj};               
                
            elseif graphIsaExpression(lhs(obj)) && nodeIsaRelation(rhs(obj)) && nodeIsaRelation(obj)
                lhsGraph = Yop.ComputationalGraph(obj.Operation, lhs(obj), leftmostExpression(rhs(obj)));
                rhsGraph = unnestRelations(rhs(obj));
                graph = [{lhsGraph}; rhsGraph(:)];                
                
            elseif nodeIsaRelation(lhs(obj)) && graphIsaExpression(rhs(obj)) && nodeIsaRelation(obj)
                lhsGraph = unnestRelations(lhs(obj));
                rhsGraph = Yop.ComputationalGraph(obj.Operation, rightmostExpression(lhs(obj)), rhs(obj));
                graph = [lhsGraph(:); {rhsGraph}];                
                
            elseif nodeIsaRelation(lhs(obj)) && nodeIsaRelation(rhs(obj)) && nodeIsaRelation(obj)
                lhsGraph = unnestRelations(lhs(obj));
                mdlGraph = Yop.ComputationalGraph(obj.Operation, rightmostExpression(lhs(obj)), leftmostExpression(rhs(obj)));
                rhsGraph = unnestRelations(rhs(obj));
                graph = [ ...
                    lhsGraph(:); ...
                    {mdlGraph}; ...
                    rhsGraph(:) ...
                    ];                
                
            else
                assert(false, ...
                    "Yop: Computational graph does not describe a relation")
                
            end            
        end
        
        function nlpForm = setToNlpForm(obj)
            % restructureToNlpForm(obj)
            % Sets an unnested graph to the following form.
            % h(x) <= 0
            % g(x) == 0
            % Presumes the graph has been unnested
            
            if length(obj) > 1
                nlpForm = [];
                for k=1:length(obj)
                    nlpForm = [nlpForm; setToNlpForm(obj(k))];
                end
                
            elseif isequal(obj.Operation, @lt) || isequal(obj.Operation, @le)
                nlpForm = Yop.ComputationalGraph( ...
                    @le, ...
                    lhs(obj) - rhs(obj), ...
                    zeros( size(lhs(obj)) ) ...
                    );
                
            elseif isequal(obj.Operation, @gt) || isequal(obj.Operation, @ge)
                nlpForm = Yop.ComputationalGraph( ...
                    @le, ...
                    rhs(obj) - lhs(obj), ...
                    zeros( size(lhs(obj)) ) ...
                    );
                
            elseif isequal(obj.Operation, @eq)
                nlpForm = Yop.ComputationalGraph( ...
                    @eq, ...
                    lhs(obj) - rhs(obj), ...
                    zeros( size(lhs(obj)) ) ...
                    );
            end
        end
    end
    
    methods % (VariableGraphInterface)
        function result = evaluateComputation(obj)
            argument = {};
            for k=1:length(obj.Argument)                
                argument = [argument(:)', {evaluateComputation(obj.Argument{k})}];
            end
            
            exceptions = Yop.FunctionException.getExceptions;
            if isaException(exceptions, obj.Operation)
                substitute = getSubstitute(exceptions, obj.Operation);
                result = substitute( argument{:} );
            else
                result = obj.Operation( argument{:} );
            end
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
        
        function l = leftmostExpression(obj)
            if graphIsaExpression(obj)
                l = obj;
            else
                l = leftmostExpression(lhs(obj));
            end
        end
        
        function r = rightmostExpression(obj)
            if graphIsaExpression(obj)
                r = obj;
            else
                r = rightmostExpression(rhs(obj));
            end
        end
        
        function bool = dependsOn(obj, variable)
            bool = false;
            for k=1:length(obj.Argument)
                bool = dependsOn(obj.Argument{k}, variable) || bool;
            end
        end
        
        function bool = graphIsaExpression(obj)
            bool = ~nodeIsaRelation(obj);
            k = length(obj.Argument);
            while bool == true && k <= length(obj.Argument)
                bool = bool && ...
                    ~nodeIsaRelation(obj.Argument{k}) && ...
                    graphIsaExpression(obj.Argument{k});
                k = k+1;
            end            
        end
        
        function bool = nodeIsaRelation(obj)
            bool = ...
                isequal(obj.Operation, @lt) || ...
                isequal(obj.Operation, @gt) || ...
                isequal(obj.Operation, @le) || ...
                isequal(obj.Operation, @ge) || ...
                isequal(obj.Operation, @ne) || ...
                isequal(obj.Operation, @eq);            
        end
        
        function bool = isIndependentInitial(obj)
            bool = false;
        end
        
        function bool = isIndependentFinal(obj)
            bool = false;
        end
        
        function bool = isaVariable(obj)
            bool = ~ismethod(Yop.MathOperations, func2str(obj.Operation));
            k = 1;
            while k <= length(obj.Argument) && bool
                bool = isaVariable(obj.Argument{k});
                k = k+1;
            end
        end
        
        function bool = isaNumeric(obj)
            bool = true;
            for k=1:length(obj.Argument)
                bool = bool && isaNumeric(obj.Argument{k});
            end
        end
        
        function obj = t0(obj)
            obj.Timepoint = Yop.getIndependentInitial;
        end
        
        function obj = tf(obj)
            obj.Timepoint = Yop.getIndependentFinal;
        end
        
        function obj = ti(obj, t_i)
            obj.Timepoint = t_i;
        end
    end
    
    methods % (DefaultChangingBehavior)
        function [s, varargout] = size(obj, varargin)
            s = size(evaluateComputation(obj), varargin{:});
            nout = max(nargout,1) - 1;
            for k=1:nout
                varargout{k} = s(k);
            end
        end
        
        function n = numel(obj)
            n = numel(evaluateComputation(obj));
        end
        
        function ind = end(obj,k,n)
            szd = size(evaluateComputation(obj));
            if k < n
                ind = szd(k);
            else
                ind = prod(szd(k:end));
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
                if ~isa(args{k}, 'Yop.Variable') && ~isa(args{k}, 'Yop.ComputationalGraph')
                    args{k} = Yop.Variable(args{k});
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