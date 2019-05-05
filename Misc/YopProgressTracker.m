% Copyright 2019, Viktor Leek
%
% This file is part of Yop.
%
% Yop is free software: you can redistribute it and/or modify it
% under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or any
% later version.
% Yop is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
% Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Yop.  If not, see <https://www.gnu.org/licenses/>.
% -------------------------------------------------------------------------
classdef YopProgressTracker < handle
    properties
        Building
        BuildFinished
        OptimizationCompleted
    end
    methods
        function obj = YopProgressTracker()                             
            obj.Building = 'Yop: Building optimal control problem.';
            obj.BuildFinished = 'Yop: Build finished. Handing over to IPOPT.';
            obj.OptimizationCompleted = 'Yop: Optimization completed.';  
        end
        
        function buildinOptimalControlProblem(obj)
            fprintf([obj.Building, '\n'])
        end
        
        function finishedBuilding(obj)
            msg = ['\b'];
            for k=1:length(obj.Building)
                msg = [msg, '\b'];
            end
            fprintf(msg);
            fprintf([obj.BuildFinished, '\n']);
        end
        
        function optimizationCompleted(obj)
            fprintf([obj.OptimizationCompleted, '\n']);
        end
        
    end
    methods (Static)
        function p = getPgt
            persistent pgt
            if isempty(pgt)
                pgt = YopProgressTracker;
            end
            p = pgt;
        end
        
        function start
            p = YopProgressTracker.getPgt;
            p.buildinOptimalControlProblem;
        end
        
        function buildFinished
            p = YopProgressTracker.getPgt;
            p.finishedBuilding;
        end
        
        function completed
            p = YopProgressTracker.getPgt;
            p.optimizationCompleted;
        end
    end
end