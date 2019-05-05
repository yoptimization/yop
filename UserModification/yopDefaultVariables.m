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
function d = yopDefaultVariables()

persistent integrationGrid
if isempty(integrationGrid)
    integrationGrid = linspace(0, 1, 100);
end

% Default variables in Yop
d = struct;

% Integration
d.integration.grid = integrationGrid;
d.integration.reltol = 1e-6;
d.integration.abstol = 1e-8;
d.integration.integratorSteps = 10000;
d.integration.outputT0 = true;
d.integration.printStats = false;
d.integration.idasOptions = struct;

d.optimization.nlp_upper_bound_inf =  1e19;
d.optimization.nlp_lower_bound_inf = -1e19;
d.inf_ub = 1e19;
d.inf_lb = -1e19;
end