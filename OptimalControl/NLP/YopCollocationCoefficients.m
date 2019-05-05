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
classdef YopCollocationCoefficients < handle
    properties
        BasisDegree
        PointsSelection
        CollocationPoints
        PolynomialBasis
        ContinuityCoefficients
        CollocationCoefficients
        QuadratureCoefficients
    end
    methods
        function obj = YopCollocationCoefficients(degree, points)
            obj.BasisDegree = degree;
            obj.PointsSelection = points;
            obj.calculateCoefficients;
        end
        
        function cj = C(obj, r, j)
            if nargin == 1
                cj = obj.CollocationCoefficients;
            else
                cj = obj.CollocationCoefficients(r, j);
            end
        end
        
        function dj = D(obj, j)
            if nargin == 1
                dj = obj.ContinuityCoefficients;
            else
                dj = obj.ContinuityCoefficients(j);
            end
        end
        
        function dt = Dt(obj, tau, j)
            Dt = zeros(obj.BasisDegree+1, 1);
            for k=1:obj.BasisDegree+1
                Dt(k) = polyval(obj.PolynomialBasis(k,:), tau);
            end
            
            if nargin == 1
                assert(false)
            elseif nargin == 2
                dt = Dt;
            else
                dt = Dt(j);
            end
        end
        
        function bj = B(obj, j)
            if nargin == 1
                bj = obj.QuadratureCoefficients;
            else
                bj = obj.QuadratureCoefficients(j);
            end
        end
        
        function dj = L(obj, j)
            if nargin == 1
                dj = obj.PolynomialBasis;
            else
                dj = obj.PolynomialBasis(j);
            end
        end
        
        function calculateCoefficients(obj)
            
            % Collocation points
            tau = [0 casadi.collocation_points(obj.BasisDegree, obj.PointsSelection)];
            
            % Coefficients of the collocation equation
            C = zeros(obj.BasisDegree+1, obj.BasisDegree+1);
            
            % Coefficients of the continuity equation
            D = zeros(obj.BasisDegree+1, 1);
            
            % Polynomial basis coefficients
            L = zeros(obj.BasisDegree+1, obj.BasisDegree+1);
            
            % Coefficients of the quadrature function
            B = zeros(obj.BasisDegree+1, 1);
            
            for j=1:obj.BasisDegree+1
                c = 1; % Polynomial coefficients in standard form: 1 + c1x1 + ...
                for r=1:obj.BasisDegree+1
                    if r ~= j
                        c = conv(c, [1, -tau(r)]);
                        c = c / (tau(j)-tau(r));
                    end
                end
                L(j,:) = c;
                D(j) = polyval(c, 1.0);
                
                dtc = polyder(c);
                for r=1:obj.BasisDegree+1
                    C(j,r) = polyval(dtc, tau(r));
                end
                
                pint = polyint(c);
                B(j) = polyval(pint, 1.0);
            end
            
            obj.PolynomialBasis = L;
            obj.ContinuityCoefficients = D;
            obj.CollocationCoefficients = C;
            obj.QuadratureCoefficients = B;
            obj.CollocationPoints = tau;
            
        end
        
        function polynomialDegree = d(obj)
            polynomialDegree = obj.BasisDegree;
        end
    end
end

























