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
classdef YopDiscretizedVariable < YopCell
    properties
        ElementDimension
        LabelGenerator
        Index
        IndexGenerator
        Timepoint       
    end
    methods
        function obj = YopDiscretizedVariable(elementDimension, labelGenerator, indexGenerator)
            obj@YopCell;
            obj.ElementDimension = elementDimension;
            obj.LabelGenerator = labelGenerator;
            obj.IndexGenerator = indexGenerator;
            
        end
        
        function returnValue = store(obj, k, r, timepoint) 
            returnValue = [];
            
            if obj.ElementDimension > 0
                
                w_kr = casadi.MX.sym(obj.LabelGenerator(k, r), obj.ElementDimension);                
                
                obj.store@YopCell(w_kr, k, r);                                
                
                obj.Index = [obj.Index, obj.getIndex(w_kr)];
                
                if nargin == 4
                    obj.Timepoint = [obj.Timepoint, timepoint];
                end
                
                returnValue = w_kr;
            end
            
        end
        
        function element = get(obj, k, r)
            element = [];
            if obj.ElementDimension > 0
                element = obj.get@YopCell(k, r);
                
            end
        end
        
        function column = getColumn(obj, k)
            column = [];
            if obj.ElementDimension > 0                
                column = [obj.Data{:, k}];
            end
        end
        
        function index = getIndex(obj, element)
            index = obj.IndexGenerator.store(element);
        end
    end
end