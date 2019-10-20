classdef FunctionObject < handle
    properties
        Argument
        Computation
    end
    methods
        function obj = FunctionObject(computation, varargin)
            
            args = cell(size(varargin));
            for k=1:length(varargin)
                assert(isa(varargin{k}, 'Yop.Variable'), "Yop: Expected arguments to be of class 'Yop.Variable'");
                args{k} = copy(varargin{k});
            end
            
            copyComputation = copy(computation);
            compInputs = computation.getInputArguments;
            copyInputs = copyComputation.getInputArguments;
            
            for k=1:length(compInputs)
                for n=1:length(varargin)
                    if isequal(compInputs{k}, varargin{n})
                        replace(copyInputs{k}, args{n});
                        break
                    end
                end
            end
            
            obj.Argument = args;
            obj.Computation = copyComputation;            
            
        end
        
        function res = evaluate(obj, varargin)
            for k=1:length(obj.Argument)
                replace(obj.Argument{k}, varargin{k});
            end
            res = evaluateComputation(obj.Computation);
        end
    end
end