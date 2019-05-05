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
classdef YopCell < handle
    properties
        Data
    end
    methods
        function obj = YopCell
            obj.Data = {};
        end
        
        function element = store(obj, element, row, column)
            obj.Data{row, column} = element;
        end
        
        function element = get(obj, row, column)
            if strcmp(row, 'end') && strcmp(column, 'end')
                element = obj.Data{end, end};
                
            elseif strcmp(row, 'end')
                element = obj.Data{end, column};
                
            elseif strcmp(column, 'end')
                element = obj.Data{row, end};
                
            else
                element = obj.Data{row, column};
            end
        end
        
        function column = getColumn(obj, k)
            column = [obj.Data{:, k}];
        end
        
        function row = getRow(obj, k)
            row = [obj.Data{k, :}];
        end
        
        function elements = getAll(obj)
            tmp = transpose(obj.Data);
            elements = vertcat(tmp{:});
        end
    end
end