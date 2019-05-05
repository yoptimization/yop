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
function na = YopNargout(model, input, expected)
na = 0;
while true
    try
        eval([getArguments(na+1) '= model(input{:});'])
        na = na+1;
    catch
        break;
    end
end

if na < expected
    model(input{:});
end

end

function args = getArguments(narg)
variablesCell = arrayfun(@(k) ['a', num2str(k) ','], 1:narg, 'UniformOutput', 0);
variables = [variablesCell{:}];
args = ['[' variables(1:end-1) ']'];
end