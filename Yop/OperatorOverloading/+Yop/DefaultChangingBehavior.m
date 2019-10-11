classdef DefaultChangingBehavior < handle
    methods
        function narg = getArgNumber(obj, methodName, methodList, varargname)
            classMeta = metaclass(obj);
            method = classMeta.MethodList({classMeta.MethodList.Name} == string(methodName));
            args = method.(methodList);
            narg = length(args);
            if narg ~= 0
                if args{end} == varargname
                    narg = narg*-1;
                end
            end
        end
        
        function narg = getNargin(obj, methodName)
            narg = obj.getArgNumber(methodName, "InputNames", "varargin");
        end
        
        function narg = getNargout(obj, methodName)
            narg = obj.getArgNumber(methodName, "OutputNames", "varargout");
        end
        
        function bool = methodTakesNoArguments(obj, methodName)
            bool = getNargin(obj, methodName) == 1;
        end
        
        function bool = methodTakesAtMostOneArgument(obj, methodName)
            bool = getNargin(obj, methodName) == -2;
        end
        
        function varargout = subsref(obj, s)
            if s(1).type == "."
                if ismethod(obj, s(1).subs)
                    nargoutMethod = abs(getNargout(obj, s(1).subs));
                    argout = cell(1, max(nargout, abs(nargoutMethod)));
                    
                    if methodTakesNoArguments(obj, s(1).subs)
                        rest = s(2:end);
                        if isempty(rest)
                            [argout{1:end}] = obj.(s(1).subs);
                        else
                            argout = {obj.(s(1).subs)};
                        end
                        
                    elseif methodTakesAtMostOneArgument(obj, s(1).subs) && ...
                            length(s) == 1
                        [argout{1:end}] = obj.(s(1).subs);
                        rest = [];
                        
                    elseif methodTakesAtMostOneArgument(obj, s(1).subs) && ...
                            s(2).type ~= "()"
                        rest = s(2:end);
                        if isempty(rest)
                            [argout{1:end}] = obj.(s(1).subs);
                        else
                            argout = {obj.(s(1).subs)};
                        end
                        
                    else % Method call with arguments
                        rest = s(3:end);
                        if isempty(rest)
                            [argout{1:end}] = obj.(s(1).subs)(s(2).subs{:});
                        else
                            argout = {obj.(s(1).subs)(s(2).subs{:})};
                        end
                        
                    end
                    
                elseif isprop(obj, s(1).subs)
                    argout = {obj.(s(1).subs)};
                    rest = s(2:end);
                    
                end
                
            elseif s(1).type == "()"
                if isnumeric(s(1).subs{1}) || ischar(s(1).subs{1})
                    argout = {Yop.ComputationalGraph(@subsref, obj, s(1))};
                    rest = s(2:end);
                    
                elseif isIndependentInitial(s(1).subs{:})
                    argout = {t0(obj)};
                    rest = s(2:end);
                    
                elseif isIndependentFinal(s(1).subs{:})
                    argout = {tf(obj)};
                    rest = s(2:end);
                    
                elseif isa(s(1).subs{:}, 'Yop.ComputationalGraph')
                    argout = {ti(obj, s(1).subs{:}.Timepoint)};
                    rest = s(2:end);
                    
                end
                
            elseif s(1).type == "{}"
                argout = cell(1,1);
                argout{1} = obj{s(1).subs{:}};
                rest = s(2:end);
            end
            
            if isempty(rest)
                varargout = argout;
            else
                varargout = cell(1, max(1, nargout));
                [varargout{1:end}] = subsref(argout{:}, rest);
            end
        end
    end
    
    methods (Abstract)
        %         [s, varargout] = size(obj, varargin);
        %         n = numel(obj);
        ind = end(obj,k,n);
    end
end