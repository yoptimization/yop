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
classdef YopNlpVariableVector < handle
    properties
        % Nlp variables
        Vector
        NlpVariable
        % Discretization
        ControlIntervals
        BasisPolynomialDegree
        CollocationPoints
        % Variables
        Independent
        State
        Algebraic
        Control
        Parameter
        IndependentInitial
        IndependentFinal
        % Dimensions
        StateDimension
        AlgebraicDimension
        ControlDimension
        ParameterDimension
    end
    methods
        
        function obj = YopNlpVariableVector(nx, nz, nu, np)
            % Variable dimensions
            obj.StateDimension     = nx;
            obj.AlgebraicDimension = nz;
            obj.ControlDimension   = nu;
            obj.ParameterDimension = np;
        end
        
        function vector = build(obj, controlIntervals, polynomialDegree, collocationPoints)            
            obj.ControlIntervals      = controlIntervals;
            obj.BasisPolynomialDegree = polynomialDegree;
            obj.CollocationPoints     = collocationPoints;
            
            w = YopVariableVector;
            obj.Independent        = YopCell();
            obj.IndependentInitial = YopDiscretizedVariable(1, @(k, r) 't0', w);
            obj.IndependentFinal   = YopDiscretizedVariable(1, @(k, r) 'tf', w);
            obj.State              = YopDiscretizedVariable(obj.nx, @(k, r) ['x_' '(' num2str(k), ',' num2str(r) ')'], w);
            obj.Algebraic          = YopDiscretizedVariable(obj.nz, @(k, r) ['z_' '(' num2str(k), ',' num2str(r) ')'], w);
            obj.Control            = YopDiscretizedVariable(obj.nu, @(k, r) ['u' '_' num2str(k)], w);
            obj.Parameter          = YopDiscretizedVariable(obj.np, @(k, r) 'p', w);   

            obj.IndependentInitial.store(1,1);
            obj.IndependentFinal.store(1,1);
            obj.Parameter.store(1,1);               
            
            for k=1:obj.K
                for r=1:obj.d+1
                    obj.Independent.store(obj.t0 + obj.dt*(k-1) + obj.dt*obj.tau(r), k, r);
                    obj.State.store(k,r, obj.t(k, r));                    
                    if r ~= 1
                        obj.Algebraic.store(k,r, obj.t(k, r));                        
                    end
                end                
                obj.Control.store(k,1, obj.t(k, 1));                
            end            
            obj.Independent.store(obj.t0 + obj.dt*obj.K, obj.K+1, 1);
            obj.State.store(obj.K+1,1, obj.t(obj.K+1, 1));
            obj.NlpVariable = w.Vector;
            vector = w.Vector;
            
        end        
        
        function [ubw, lbw] = setBoxConstraints(obj, ocp)
            
            ubw = zeros(obj.numberOfVariables,1);
            lbw = ones(obj.numberOfVariables,1);

            ubw(obj.IndependentInitial.Index) = ocp.getIndependentInitialUpperBound;
            lbw(obj.IndependentInitial.Index) = ocp.getIndependentInitialLowerBound;

            ubw(obj.IndependentFinal.Index) = ocp.getIndependentFinalUpperBound;
            lbw(obj.IndependentFinal.Index) = ocp.getIndependentFinalLowerBound;

            ubw(obj.Parameter.Index) = ocp.getParameterUpperBound;
            lbw(obj.Parameter.Index) = ocp.getParameterLowerBound;

            ubw(obj.State.Index) = repmat(ocp.getStateUpperBound, obj.numberOfStateEntries, 1);
            lbw(obj.State.Index) = repmat(ocp.getStateLowerBound, obj.numberOfStateEntries, 1);

            ubw(obj.State.Index(1:(obj.nx))) = ocp.getStateInitialUpperBound;
            lbw(obj.State.Index(1:(obj.nx))) = ocp.getStateInitialLowerBound;

            ubw(obj.State.Index((end-obj.nx+1):end)) = ocp.getStateFinalUpperBound;
            lbw(obj.State.Index((end-obj.nx+1):end)) = ocp.getStateFinalLowerBound;

            ubw(obj.Algebraic.Index) = repmat(ocp.getAlgebraicUpperBound, obj.numberOfAlgebraicEntries);
            lbw(obj.Algebraic.Index) = repmat(ocp.getAlgebraicLowerBound, obj.numberOfAlgebraicEntries);

            ubw(obj.Control.Index) = repmat(ocp.getControlUpperBound, obj.ControlIntervals, 1);
            lbw(obj.Control.Index) = repmat(ocp.getControlLowerBound, obj.ControlIntervals, 1);

            ubw(obj.Control.Index(1:(obj.nu))) = ocp.getControlInitialUpperBound;
            lbw(obj.Control.Index(1:(obj.nu))) = ocp.getControlInitialLowerBound;

            ubw(obj.Control.Index((end-obj.nu+1):end)) = ocp.getControlFinalUpperBound;
            lbw(obj.Control.Index((end-obj.nu+1):end)) = ocp.getControlFinalLowerBound;
        end   
        
        function w0 = setInitialGuess(obj, initialGuess)
            w0 = nan(obj.numberOfVariables, 1);            
            w0(obj.IndependentInitial.Index) = initialGuess.independentInitial;
            w0(obj.IndependentFinal.Index) = initialGuess.independentFinal;   
            w0(obj.Parameter.Index) = initialGuess.parameter;            
            w0(obj.State.Index) = initialGuess.state(obj.State.Timepoint);            
            w0(obj.Algebraic.Index) = initialGuess.algebraic(obj.Algebraic.Timepoint);            
            w0(obj.Control.Index) = initialGuess.control(obj.Control.Timepoint);
        end        
        
        function t_kr = t(obj, k, r)
            t_kr = obj.Independent.get(k, r);
        end     
        
        function x_kr = x(obj, k, r)
            x_kr = obj.State.get(k, r);
        end
        
        function z_kr = z(obj, k, r)
            z_kr = obj.Algebraic.get(k, r);
        end
        
        function u_kr = u(obj, k)
            u_kr = obj.Control.get(k, 1);
        end
        
        function p = p(obj)
            p = obj.Parameter.get(1, 1);
        end
        
        function t = t0(obj)
            t = obj.IndependentInitial.get(1, 1);
        end
        
        function t = tf(obj)
            t = obj.IndependentFinal.get(1, 1);
        end
        
        function h = dt(obj)
            h = (obj.tf - obj.t0)/obj.K;
        end
        
        function tau_r = tau(obj, r)
            tau_r = obj.CollocationPoints(r);
        end
       
        function controlIntervals = K(obj)
            controlIntervals = obj.ControlIntervals;            
        end
        
        function polynomialDimension = d(obj)
            polynomialDimension = obj.BasisPolynomialDegree;
        end
        
        function numberOfStates = nx(obj)
            numberOfStates = obj.StateDimension;
        end
        
        function numberOfAlgebraics = nz(obj)
            numberOfAlgebraics = obj.AlgebraicDimension;
        end
        
        function numberOfControls = nu(obj)
            numberOfControls = obj.ControlDimension;
        end
        
        function numberOfParameters = np(obj)
            numberOfParameters = obj.ParameterDimension;
        end
        
        function Nv = numberOfVariables(obj)
            Np = 1 + 1 + obj.np;
            Nx = obj.K*(obj.d+1)*obj.nx + obj.nx;
            Nz = obj.K*obj.d*obj.nz;
            Nu = obj.K*obj.nu;
            Nv = Np + Nx + Nz + Nu;
        end
        
        function Nx = numberOfStateEntries(obj)
            if obj.nx > 0
                Nx = obj.K*(obj.d+1) + 1;
            else
                Nx = 0;
            end
        end
        
        function Nz = numberOfAlgebraicEntries(obj)
            if obj.nz > 0
                Nz = obj.K*obj.d;
            else
                Nz = 0;
            end
        end
        
    end
    

end






















