classdef debug < handle
    
    properties
        enabled
    end
    
    methods
        function obj = debug(enable)
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
        
        function validate_size(is, should)
            if yop.debug().enabled
                if ~size(is)==size(should)
                end
            end                        
        end
    end
end