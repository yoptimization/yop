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
function f = YopInterpolant(xdata, ydata)
% ydata - times grows with number of columns

[rows, ~] = size(ydata);
y = [];
t = casadi.MX.sym('t');
for k=1:rows
    yk = casadi.interpolant('yk', 'linear', {xdata}, ydata(k,:));
    y = [y; yk(t)];
end

f = casadi.Function('YopInterpolant', {t}, {y});
end