classdef YopFunction < handle
    properties        
        Timepoint
        Index
        Function
    end
    methods
        function obj = YopFunction(expression, name, argin)
            obj.Timepoint = expression.Timepoint;
            obj.Index = expression.Index;
            obj.Function = casadi.Function( ...
                name, ...
                cellfun(@(v) v.evaluate, argin, 'UniformOutput', false), ...
                {expression.evaluate} ...
                );
            
        end
        
        function value = evaluate(obj, varargin)
            for k=1:length(varargin)
                if isa(varargin{k}, 'YopVar')
                    varargin{k} = varargin{k}.evaluate;
                end
            end
            value = YopVar(obj.Function(varargin{:}));
        end
        
    end
    methods (Static)
        function evaluator = constructor(expression, name, argin)
            % Går att överlagra subsref för att slippa skicka
            % funktionshandtag.
            obj = YopFunction(expression, name, argin);
            evaluator = @(varargin) obj.evaluate(varargin{:});
        end
    end
end