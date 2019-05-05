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
classdef YopInitialGuess < handle
    properties
        Signals
        Parameters
    end
    methods
        function obj = YopInitialGuess(varargin)
            
            ip = inputParser;
            ip.FunctionName = 'YopInitialGuess';
            ip.PartialMatching = false;
            ip.KeepUnmatched = false;
            ip.CaseSensitive = true;            
            
            ip.addParameter('parameters', []);
            ip.addParameter('parameterValues', []);
            ip.addParameter('signals', []);
            ip.addParameter('signalValues', []);
            
            ip.parse(varargin{:});
            
            signals = ip.Results.signals;
            values = ip.Results.signalValues;
            
            [~, columns] = size(values);
            if columns == 1
                values = [values, values];
                values(1,2) = values(1,1)+1;
            end
            
            obj.Signals = YopInitialGuessEntry(signals, values);
            obj.Parameters = YopInitialGuessEntry(ip.Results.parameters, ip.Results.parameterValues);
            
        end
        
        function y = signal(obj, expression)
            getter = casadi.Function('y', {obj.Signals.Variables}, {expression});
            y = full(getter(obj.Signals.Values));
        end
        
        function p = parameter(obj, expression)
            getter = casadi.Function('p', {obj.Parameters.Variables}, {expression});
            p = full(getter(obj.Parameters.Values));
        end
        
    end
end