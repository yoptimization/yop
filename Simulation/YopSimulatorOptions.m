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
classdef YopSimulatorOptions < handle
    properties
        grid
        output_t0 = true;
        print_stats = false;
        abstol
        abstolv
        calc_ic
        disable_internal_warnings
        first_time
        fsens_err_con
        init_xdot
        interpolation_type
        linear_solver
        linear_solver_options
        max_krylov
        max_multistep_order
        max_num_steps 
        max_order
        max_step_size
        newton_scheme
        nonlin_conv_coeff        
        reltol
        second_order_correction
        sensitivity_method
        step0
        steps_per_checkpoint
        stop_at_end
        suppress_algebraic
        use_preconditioner
        
    end
    methods
        function obj = YopSimulatorOptions(varargin)
            obj.set(varargin{:});            
        end
        
        function set(obj, varargin)
            
            ip = inputParser;
            ip.FunctionName = 'YopSimulatorOptions';
            ip.PartialMatching = false;
            ip.KeepUnmatched = false;
            ip.CaseSensitive = true;
            
            ip.addParameter('grid', []);
            ip.addParameter('printStats', []);
            ip.addParameter('abstol', []);
            ip.addParameter('absoluteToleranceVector', []);
            ip.addParameter('calcInitialConditions', []);
            ip.addParameter('disableIdasInternalWarnings', []);
            ip.addParameter('firstTime', []);                       
            ip.addParameter('forwardSensitivityErrorControl', []);
            ip.addParameter('stateDerivativeInitialValue', []);
            ip.addParameter('interpolationType', []);
            ip.addParameter('linearSolver', []);
            ip.addParameter('linearSolverOptions', []);
            ip.addParameter('maxKrylovSize', []);
            ip.addParameter('maxMultistepOrder', []);
            ip.addParameter('maxIntegratorSteps', []);
            ip.addParameter('maxIntegrationOrder', []);
            ip.addParameter('maxStepSize', []);
            ip.addParameter('newtonScheme', []);
            ip.addParameter('nonlinearConvergenceCoefficient', []);
            ip.addParameter('reltol', []);
            ip.addParameter('secondOrderCorrection', []);
            ip.addParameter('sensitivityMethod', []);
            ip.addParameter('initialStepSize', []);
            ip.addParameter('stepsPerCheckpoint', []);
            ip.addParameter('stopAtEnd', []);
            ip.addParameter('supressAlgebraic', []);
            ip.addParameter('usePreconditioner', []);
                        
            ip.parse(varargin{:});
            
            if ~isempty(ip.Results.grid)
                obj.grid = ip.Results.grid;
            end          
            
            if ~isempty(ip.Results.printStats)
                obj.print_stats = ip.Results.printStats;
            end
            
            if ~isempty(ip.Results.abstol)
                obj.abstol = ip.Results.abstol;
            end            
                         
            if ~isempty(ip.Results.absoluteToleranceVector)
                obj.abstolv = ip.Results.absoluteToleranceVector;
            end
            
            if ~isempty(ip.Results.calcInitialConditions)
                obj.calc_ic = ip.Results.calcInitialConditions;
            end
            
            if ~isempty(ip.Results.disableIdasInternalWarnings)
                obj.disable_internal_warnings = ip.Results.disableIdasInternalWarnings;
            end
            
            if ~isempty(ip.Results.firstTime)
                obj.first_time = ip.Results.firstTime;
            end            
                        
            if ~isempty(ip.Results.forwardSensitivityErrorControl)
                obj.fsens_err_con = ip.Results.forwardSensitivityErrorControl;
            end            
                        
            if ~isempty(ip.Results.stateDerivativeInitialValue)
                obj.init_xdot = ip.Results.stateDerivativeInitialValue;
            end
            
            if ~isempty(ip.Results.interpolationType)
                obj.interpolation_type = ip.Results.interpolationType;
            end
            
            if ~isempty(ip.Results.linearSolver)
                obj.linear_solver = ip.Results.linearSolver;
            end
            
            if ~isempty(ip.Results.linearSolverOptions)
                obj.linear_solver_options = ip.Results.linearSolverOptions;
            end
            
            if ~isempty(ip.Results.maxKrylovSize)
                obj.max_krylov = ip.Results.maxKrylovSize;
            end
            
            if ~isempty(ip.Results.maxMultistepOrder)
                obj.max_multistep_order = ip.Results.maxMultistepOrder;
            end
            
            if ~isempty(ip.Results.maxIntegratorSteps)
                obj.max_num_steps = ip.Results.maxIntegratorSteps;
            end
            
            if ~isempty(ip.Results.maxIntegrationOrder)
                obj.max_order = ip.Results.maxIntegrationOrder;
            end
            
            if ~isempty(ip.Results.maxStepSize)
                obj.max_step_size = ip.Results.maxStepSize;
            end
            
            if ~isempty(ip.Results.newtonScheme)
                obj.newton_scheme = ip.Results.newtonScheme;
            end
            
            if ~isempty(ip.Results.nonlinearConvergenceCoefficient)
                obj.nonlin_conv_coeff = ip.Results.nonlinearConvergenceCoefficient;                
            end
            
            if ~isempty(ip.Results.reltol)
                obj.reltol = ip.Results.reltol;
            end
            
            if ~isempty(ip.Results.secondOrderCorrection)
                obj.second_order_correction = ip.Results.secondOrderCorrection;
            end
            
            if ~isempty(ip.Results.sensitivityMethod)
                obj.sensitivity_method = ip.Results.sensitivityMethod;
            end
            
            if ~isempty(ip.Results.initialStepSize)
                obj.step0 = ip.Results.initialStepSize;
            end
            
            if ~isempty(ip.Results.stepsPerCheckpoint)
                obj.steps_per_checkpoint = ip.Results.stepsPerCheckpoint;
            end
            
            if ~isempty(ip.Results.stopAtEnd)
                obj.stop_at_end = ip.Results.stopAtEnd;
            end
            
            if ~isempty(ip.Results.supressAlgebraic)
                obj.suppress_algebraic = ip.Results.supressAlgebraic;                
            end
            
            if ~isempty(ip.Results.usePreconditioner)
                obj.use_preconditioner = ip.Results.usePreconditioner;
            end                      
            
        end
        
        function options = getOptions(obj)
            options = struct;
            f = fields(obj);
            for k=1:length(f)
                if ~isempty(obj.(f{k}))
                    options.(f{k}) = obj.(f{k});
                end
            end
        end
                  
    end
end