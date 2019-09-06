classdef YopTimepoint < handle
    properties
        Timepoint
    end
    methods
        function obj = YopTimepoint(timepoint)
            obj.Timepoint = timepoint;
        end
        
        function t = timepoint(obj, expression)
            if nargin == 1
                t = obj;
            elseif nargin == 2
                % varTimed
            end
        end
    end
end

%% 
% t2 = YopTimepoint(2);
% expr(t2);
% t2(expr);
% t_0(expr);
% expr(t_0);

% t_0, t_f både parameter och tidpunkt, måste därför specialhanteras i
% YopVar

% t_0 -> parameter
% expr(t_0) -> varTimed, t_0 timepoint
% t_0(expr) -> varTimed