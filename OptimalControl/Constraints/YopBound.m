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
classdef YopBound < handle
    properties
        Bound
    end
    methods
        function obj = YopBound(bound)
            if nargin == 1
                obj.Bound = bound;
            end
        end
        function set(obj, bound)
            for k=1:length(obj)
                if length(bound) == 1
                    bk = bound;
                elseif isempty(bound)
                    bk = [];
                else
                    bk = bound(k);
                end
                obj(k).Bound = bk;
            end
        end
        function bound = get(obj)
            bound = vertcat(obj.Bound);
        end
    end
end