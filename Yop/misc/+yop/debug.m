classdef debug < handle
    
    properties
        enabled
    end
    
    methods
        function obj = debug(enable)
            % DEBUG Runtime debugging
            % enable by: yop.debug(true);
            % disable: yop.debug(false);
            % test if enabled: yop.debug().enabled
            
            persistent singleton
            if isempty(singleton) && nargin == 0
                obj.enabled = false;
                singleton = obj;
                
            elseif ~isempty(singleton) && nargin == 0
                obj = singleton;
                
            elseif isempty(singleton)
                obj.enabled = enable;
                singleton = obj;
                
            else
                singleton.enabled = enable;
                obj = singleton;
                
            end
        end
    end
    
    methods (Static)        
        
        function validate_size(is, operation, varargin)
            if yop.debug().enabled
                for k=1:length(varargin)
                    varargin{k} = ones(size(varargin{k}));
                end
                if ~isequal(size(is), size(operation(varargin{:})))
                    yop.assert(false, yop.messages.debug_operation_wrong_size);
                end
            end                        
        end
    end
end