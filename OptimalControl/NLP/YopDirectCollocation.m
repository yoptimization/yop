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
classdef YopDirectCollocation < handle
    properties
        Constraints
        ControlIntervals
        PolynomialDegree
    end
    methods
        
        function obj = YopDirectCollocation(controlIntervals, polynomialDegree)
            obj.ControlIntervals = controlIntervals;
            obj.PolynomialDegree = polynomialDegree;
            obj.Constraints = YopNlpPathConstraint;
        end
        
        function J = discretizeObjective(obj, ocp, collocationCoefficients, nlpVariable)            
            cc = collocationCoefficients;
            w = nlpVariable;
            J = 0;
            K = obj.ControlIntervals;
            for k=1:K
                for r=1:cc.d+1
                    Lkr = ocp.getLagrange(w.t(k,r), w.x(k,r), w.z(k,r), w.u(k), w.p);
                    J = J + w.dt*cc.B(r)*Lkr;
                end
            end
            J = J + ocp.getMayer(w.t(K+1,1), w.x(K+1,1), w.z(K,cc.d+1), w.u(K), w.p);
        end
        
        function constraints = buildConstraints(obj, ocp, collocationCoefficients, nlpVariable)
            cc = collocationCoefficients;
            w = nlpVariable;

            g = obj.Constraints;

            g.initial(ocp.getInitial(w.t(1,1), w.x(1,1), w.z(1,1), w.u(1), w.p));
            
            K = obj.ControlIntervals;
            for k=1:K
                
                % z(k,1) �r problem (radau-punkter vid DAE kan l�sa)
                g.path(ocp.getPath(w.t(k,1), w.x(k,1), w.z(k,1), w.u(k), w.p));
                
                for j=2:cc.d+1
                    
                    g.strictPath(ocp.getStrictPath(w.t(k,j), w.x(k,j), w.z(k,j), w.u(k), w.p));
                    
                    dp = 0;
                    for r=1:cc.d+1
                        dp = dp + cc.C(r, j)*w.x(k, r);
                    end
                    
                    dx = ocp.getDifferentialEquation(w.t(k,j), w.x(k,j), w.z(k,j), w.u(k), w.p);
                    alg = ocp.AlgebraicEquation(w.t(k,j), w.x(k,j), w.z(k,j), w.u(k), w.p);
                    g.dynamics(( dp - w.dt*dx ));
                    g.dynamics(( alg ));            
                end
                
                pk_end = 0;
                for r=1:cc.d+1
                    pk_end = pk_end + cc.D(r)*w.x(k,r);
                end
                g.dynamics( pk_end - w.x(k+1, 1) );
            end
                        
            % Terminal constraints
            g.final(ocp.getFinal(w.t(K+1,1), w.x(K+1,1), w.z(K,cc.d+1), w.u(K), w.p));
            constraints = g.Vector;
            
        end  
        
        function [ubg, lbg] = setBounds(obj, ocp)                        
            ubg = zeros(size(obj.Constraints.Vector));
            lbg = zeros(size(obj.Constraints.Vector));
            
            ubg(obj.Constraints.Initial) = ocp.getInitialUpperBound;
            lbg(obj.Constraints.Initial) = ocp.getInitialLowerBound;
            ubg(obj.Constraints.Final) = ocp.getFinalUpperBound;
            lbg(obj.Constraints.Final) = ocp.getFinalLowerBound;
            ubg(obj.Constraints.StrictPath) = repmat(ocp.getStrictPathUpperBound, obj.ControlIntervals*obj.PolynomialDegree, 1);
            lbg(obj.Constraints.StrictPath) = repmat(ocp.getStrictPathLowerBound, obj.ControlIntervals*obj.PolynomialDegree, 1);
            ubg(obj.Constraints.Path) = repmat(ocp.getPathUpperBound, obj.ControlIntervals, 1);
            lbg(obj.Constraints.Path) = repmat(ocp.getPathLowerBound, obj.ControlIntervals, 1);          
            
        end
                
    end
end



















