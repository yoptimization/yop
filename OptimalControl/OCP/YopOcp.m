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
classdef YopOcp < handle
    
    properties                
        Systems
        Connections        
        Independent        
        State
        Algebraic
        Control
        Parameter
        DifferentialEquation
        AlgebraicEquation
        
        Objective
        LagrangeTerm
        MayerTerm
        
        Constraints
        
        Box
        BoxInitial
        BoxFinal
        
        Path
        PathStrict
        Initial
        Final
        
        Scaling
        
        Nlp
        NlpParametrization
        CollocationCoefficients
        NlpVector
        DirectCollocation
        
    end
    
    methods % main functionality
        function obj = YopOcp()
        end
        
        function min(obj, expression)
            if nargin == 1
                obj.parseObjective('min', {});
            else
                obj.parseObjective('min', expression);
            end
        end
        
        function max(obj, expression)
            if nargin == 1
                obj.parseObjective('max', {});
            else
                obj.parseObjective('max', expression);
            end
        end
        
        function st(obj, varargin)
            ip = inputParser;
            ip.FunctionName = 'st';
            ip.PartialMatching = false;
            ip.KeepUnmatched = false;
            ip.CaseSensitive = true;
            
            yopCustomPropertyNames;
            ip.addParameter(userSystems, []);
            ip.addParameter(userConnections, []);
            if isstring(varargin{3})
                ip.parse(varargin{1:4});
            else
                ip.parse(varargin{1:2});
            end
            
            obj.Systems = ip.Results.(userSystems);
            obj.Connections = ip.Results.(userConnections);
            obj.addConstraints(varargin(3:length(varargin)));            
                        
        end
        
        function addConstraints(obj, constraints)
            obj.Constraints = [obj.Constraints, constraints];
        end
        
        % Multi-phase
        function solution = solve(obj, varargin) 
            YopProgressTracker.start
            
            ip = inputParser;
            ip.FunctionName = 'solve';
            ip.PartialMatching = false;
            ip.KeepUnmatched = false;
            ip.CaseSensitive = true;
            
            ip.addParameter('initialGuess', []);
            ip.addParameter('collocationPoints', 'legendre');
            ip.addParameter('polynomialDegree', 5);
            ip.addParameter('controlIntervals', 100*ones(length(obj),1));
            ip.addParameter('ipopt', struct);
            
            %Test for uninterpretable options
            ip.parse(varargin{:})             
            
            obj.build(varargin{:});
            obj.parameterize(varargin{:});
            
            YopProgressTracker.buildFinished
            solution = obj.optimize(varargin{:});     
            
            YopProgressTracker.completed
            
        end     
               
        % Multi-phase
        function build(obj, varargin)
            ip = inputParser;
            ip.FunctionName = 'build';
            ip.PartialMatching = false;
            ip.KeepUnmatched = true;
            ip.CaseSensitive = true;
            
            ip.addParameter('collocationPoints', 'legendre');
            ip.addParameter('polynomialDegree', 5);
            ip.addParameter('controlIntervals', 100*ones(length(obj),1));
            
            ip.parse(varargin{:})
            
            collocationPoints = ip.Results.collocationPoints;
            polynomialDegree = ip.Results.polynomialDegree;
            controlIntervals = ip.Results.controlIntervals;
            
            if length(controlIntervals) < length(obj)
                controlIntervals = controlIntervals*ones(length(obj), 1);
            end            
            
            for k=1:length(obj)                                
                obj(k).mapScaling;
                
                obj(k).Independent = YopOcpVariable.constructor(YopIndependentVariable.getIndependentVariable);
                obj(k).State       = YopOcpVariable.constructor(obj(k).getSystemStates);
                obj(k).Algebraic   = YopOcpVariable.constructor(obj(k).getSystemAlgebraics);
                obj(k).Control     = YopOcpVariable.constructor(obj(k).getSystemControls);
                obj(k).Parameter   = YopOcpVariable.constructor(obj(k).getSystemParameters);
                
                obj(k).setDifferentialEquation;
                obj(k).setAlgebraicEquation;
                obj(k).setObjective;
                obj(k).parseConstraints;
                
                obj(k).CollocationCoefficients  = YopCollocationCoefficients(...
                    polynomialDegree, ...
                    collocationPoints ...
                    );
                
                obj(k).NlpVector = YopNlpVariableVector(...
                    obj(k).getNumberOfStates, ...
                    obj(k).getNumberOfAlgebraics, ...
                    obj(k).getNumberOfControls, ...
                    obj(k).getNumberOfParameters ...
                    );
                
                wk = obj(k).NlpVector.build( ...
                    controlIntervals(k), ...
                    polynomialDegree, ...
                    obj(k).CollocationCoefficients.CollocationPoints ...
                    );
                
                obj(k).DirectCollocation = YopDirectCollocation(...
                    controlIntervals(k), ...
                    polynomialDegree ...
                    );
                
                Jk = obj(k).DirectCollocation.discretizeObjective(...
                    obj(k), ...
                    obj(k).CollocationCoefficients, ...
                    obj(k).NlpVector ...
                    );
                
                gk = obj(k).DirectCollocation.buildConstraints(...
                    obj(k), ...
                    obj(k).CollocationCoefficients, ...
                    obj(k).NlpVector ...
                    );
                
                obj(k).Nlp = struct;
                obj(k).Nlp.Variable = wk;
                obj(k).Nlp.Objective = Jk;
                obj(k).Nlp.Constraint = gk;
            end
        end
        
        % Multi-phase
        function parameterize(obj, varargin)
            ip = inputParser;
            ip.FunctionName = 'parameterize';
            ip.PartialMatching = false;
            ip.KeepUnmatched = true;
            ip.CaseSensitive = true;            
            ip.addParameter('initialGuess', []);            
            ip.parse(varargin{:});
            
            % Hantera multifas-fallet
            initialGuess = ip.Results.initialGuess;
            
            for k=1:length(obj)                
                obj(k).mapBoxConstraints;
                
                [ubw, lbw] = obj(k).NlpVector.setBoxConstraints(obj(k));
                
                w0 = obj(k).NlpVector.setInitialGuess(...
                    obj(k).parseInitialGuess(initialGuess));
                
                [ubg, lbg] = obj(k).DirectCollocation.setBounds(obj(k));
                
                obj(k).Nlp.Upper = ubw;
                obj(k).Nlp.Lower = lbw;
                obj(k).Nlp.ConstraintUpper = ubg;
                obj(k).Nlp.ConstraintLower = lbg;
                obj(k).Nlp.InitialGuess = w0;
            end
        end
        
        % Multi-phase
        function solution = optimize(obj, varargin)
            ip = inputParser;
            ip.FunctionName = 'optimize';
            ip.PartialMatching = false;
            ip.KeepUnmatched = true;
            ip.CaseSensitive = true;
            
            ip.addParameter('ipopt', struct);
            
            ip.parse(varargin{:})
            
            options.ipopt = ip.Results.ipopt;
                        
            J = obj.getNlpObjective;
            w = obj.getNlpVariable;
            g = obj.getNlpConstraint;
            w0 = obj.getNlpInitialGuess;
            ubw = obj.getNlpUpper;
            lbw = obj.getNlpLower;
            ubg = obj.getNlpConstraintUpper;
            lbg = obj.getNlpConstraintLower;
            
            nx = obj(1).getNumberOfStates;
            np = obj(1).getNumberOfParameters;
            
            for k=1:(length(obj)-1)              
                % S�tta ihop parametrar?
                
                g = vertcat(g, obj(k).NlpVector.IndependentFinal.get(1,1)-obj(k+1).NlpVector.IndependentInitial.get(1,1));
                lbg(end+1) = 0;
                ubg(end+1) = 0;
                
                g = vertcat(g, obj(k+1).NlpVector.IndependentFinal.get(1,1)-obj(k+1).NlpVector.IndependentInitial.get(1,1));
                lbg(end+1) = 0;
                ubg(end+1) = inf;
                
                g = vertcat(g, obj(k).NlpVector.Parameter.get(1,1)-obj(k+1).NlpVector.Parameter.get(1,1));
                lbg(end+1:end+np) = zeros(np, 1);
                ubg(end+1:end+np) = zeros(np, 1);
                
                g = vertcat(g, obj(k).NlpVector.State.get('end',1)-obj(k+1).NlpVector.State.get(1,1));
                lbg(end+1:end+nx) = zeros(nx, 1);
                ubg(end+1:end+nx) = zeros(nx, 1);
                
            end
                        
            nlp = struct(...
                'f', J, ...
                'x', w, ...
                'g', g ...
                );
            
            solver = casadi.nlpsol('S', 'ipopt', nlp, options);            
            nlpSolution = solver(...
                'x0',  w0, ...
                'ubx', ubw, ...
                'lbx', lbw, ...
                'ubg', ubg, ...
                'lbg', lbg ...
                );
            
            solution(length(obj),1) = YopOcpResults;
            solution.parseResults(obj, solver.stats, nlpSolution);
        end
        
        function nlp = getNlp(obj)
            nlp = vertcat(obj.Nlp);
        end
        
        function objective = getNlpObjective(obj)
            objective = sum(vertcat(obj.getNlp.Objective));
        end
        
        function variable = getNlpVariable(obj)
            variable = vertcat(obj.getNlp.Variable);
        end
        
        function constraint = getNlpConstraint(obj)
            constraint = vertcat(obj.getNlp.Constraint);
        end
        
        function upper = getNlpUpper(obj)
            upper = vertcat(obj.getNlp.Upper);
        end
        
        function lower = getNlpLower(obj)
            lower = vertcat(obj.getNlp.Lower);
        end
        
        function upper = getNlpConstraintUpper(obj)
            upper = vertcat(obj.getNlp.ConstraintUpper);
        end
        
        function lower = getNlpConstraintLower(obj)
            lower = vertcat(obj.getNlp.ConstraintLower);
        end
        
        function initialGuess = getNlpInitialGuess(obj)
            initialGuess = vertcat(obj.getNlp.InitialGuess);
        end
            

    end
    
    methods % Systems related
        
        function input = getInput(obj)
            input = {...
                YopIndependentVariable.getIndependentVariable, ...
                obj.getSystemStates, ...
                obj.getSystemAlgebraics, ...
                obj.getSystemControls, ...
                obj.getSystemParameters ...
                };
        end
        
        function nx = getNumberOfStates(obj)
            nx = length(obj.getSystemStates);
        end
        
        function nz = getNumberOfAlgebraics(obj)
            nz = length(obj.getSystemAlgebraics);
        end
        
        function nu = getNumberOfControls(obj)
            nu = length(obj.getSystemControls);
        end
        
        function np = getNumberOfParameters(obj)
            np = length(obj.getSystemParameters);
        end
        
        function states = getSystemStates(obj)
            arr = YopArray;
            arrayfun(@(e) arr.store(e.getState), obj.Systems);
            states = arr.getElements;
        end
        
        function algebraics = getSystemAlgebraics(obj)
            arr = YopArray;
            arrayfun(@(e) arr.store([e.getAlgebraic; e.getExternalInput]), obj.Systems);
            algebraics = arr.getElements;
        end
        
        function controls = getSystemControls(obj)
            arr = YopArray;
            arrayfun(@(e) arr.store(e.getControl), obj.Systems);
            controls = arr.getElements;
        end
        
        function parameters = getSystemParameters(obj)
            arr = YopArray;
            arrayfun(@(e) arr.store(e.getParameter), obj.Systems)
            parameters = arr.getElements;
        end
        
        function ode = getSystemDifferentialEquation(obj)
            arr = YopArray;
            arrayfun(@(e) arr.store(e.getDifferentialEquation), obj.Systems);
            ode = arr.getElements;
        end
        
        function alg = getSystemAlgebraicEquation(obj)
            arr = YopArray;
            arrayfun(@(e) arr.store(e.getAlgebraicEquation), obj.Systems);
            arrayfun(@(e) arr.store(e.getConnection), obj.Connections);
            alg = arr.getElements;
        end
        
    end
    
    methods % Parsing
        
        function parseObjective(obj, objective, expression)
             obj.Objective = YopObjectiveFunction(objective, expression);
        end
                
        function parseConstraints(obj)
            obj.Box = [];
            obj.BoxInitial = [];
            obj.BoxFinal = [];
            obj.Path = [];
            obj.PathStrict = [];
            obj.Initial = [];
            obj.Final = [];

            for k=1:length(obj.Constraints)
                constraint = obj.Constraints{k};
                
                if YopBoxConstraint.isMember(constraint)
                    obj.Box = [obj.Box; ...
                        YopBoxConstraint(constraint)];
                    
                elseif YopBoxInitialConstraint.isMember(constraint)
                    obj.BoxInitial = [obj.BoxInitial; ...
                        YopBoxInitialConstraint(constraint)];
                    
                elseif YopBoxFinalConstraint.isMember(constraint)
                    obj.BoxFinal = [obj.BoxFinal; ...
                        YopBoxFinalConstraint(constraint)];
                    
                elseif YopPathConstraint.isMember(constraint)
                    obj.Path = [obj.Path; ...
                        YopPathConstraint(constraint, obj.getInput, obj.getDescaling)];
                        
                elseif YopPathStrictConstraint.isMember(constraint)
                    obj.PathStrict = [obj.PathStrict; ...
                        YopPathStrictConstraint(constraint, obj.getInput, obj.getDescaling)];
                    
                elseif YopBoundaryInitialConstraint.isMember(constraint)
                    obj.Initial = [obj.Initial; ...
                        YopBoundaryInitialConstraint(constraint, obj.getInput, obj.getDescaling)];
                    
                elseif YopBoundaryFinalConstraint.isMember(constraint)
                    obj.Final = [obj.Final; ...
                        YopBoundaryFinalConstraint(constraint, obj.getInput, obj.getDescaling)];
                    
                else
                    assert(false, 'Yop: Constraint not recognized')
                    
                end
            end
            
        end
        
        function mapBoxConstraints(obj)
            variables = [obj.Independent; obj.State; obj.Algebraic; obj.Control; obj.Parameter];
            
            if ~isempty(obj.Box)
                boxComponents = obj.Box.getComponents;
                for n=1:length(boxComponents)
                    component = boxComponents(n);
                    
                    for k=1:length(variables)                        
                        variable = variables(k);
                        
                        if component.dependsOn(variable.Variable)
                            variable.Upper = component.Upper;
                            variable.Lower = component.Lower;
                            break;
                        end
                    end
                end
            end
            
            if ~isempty(obj.BoxInitial)
                boxInitialComponents = obj.BoxInitial.getComponents;
                for n=1:length(boxInitialComponents)
                    component = boxInitialComponents(n);
                    
                    for k=1:length(variables)
                        variable = variables(k);
                        
                        if component.dependsOn(variable.Variable)
                            variable.InitialUpper = component.Upper;
                            variable.InitialLower = component.Lower;
                            break;
                        end
                    end
                end
            end
            
            if ~isempty(obj.BoxFinal)
                boxFinalComponents = obj.BoxFinal.getComponents;
                for n=1:length(boxFinalComponents)
                    component = boxFinalComponents(n);
                    
                    for k=1:length(variables)
                        variable = variables(k);
                        
                        if component.dependsOn(variable.Variable)
                            variable.FinalUpper = component.Upper;
                            variable.FinalLower = component.Lower;
                            break;
                        end
                    end
                end
            end
            
        end        
                
        function initialGuess = parseInitialGuess(obj, userInitialGuess)
            variables.State     = obj.getSystemStates;
            variables.Algebraic = obj.getSystemAlgebraics;
            variables.Control   = obj.getSystemControls;
            variables.Parameter = obj.getSystemParameters;
            
            if isempty(userInitialGuess)
                values.Independent = [0, 1];

                if obj.getNumberOfStates > 0
                    values.State = ones(obj.getNumberOfStates, 2);
                else
                    values.State = [];
                end
                
                if obj.getNumberOfAlgebraics > 0
                    values.Algebraic = ones(obj.getNumberOfAlgebraics, 2);
                else
                    values.Algebraic = [];
                end
                
                if obj.getNumberOfControls > 0
                    values.Control = ones(obj.getNumberOfControls, 2);
                else
                    values.Control = [];
                end
                
                if obj.getNumberOfParameters > 0
                    values.Parameter = ones(obj.getNumberOfParameters, 1);
                else
                    values.Parameter = [];
                end   
                
            else
                values.Independent = obj.Independent.scale( ...
                    userInitialGuess.signal(YopIndependentVariable.getIndependentVariable) ...
                    );
                
                values.State = obj.State.scale( ...
                    userInitialGuess.signal(obj.getSystemStates) ...
                    );
                
                values.Algebraic = obj.Algebraic.scale( ...
                    userInitialGuess.signal(obj.getSystemAlgebraics) ...
                    );
                
                values.Control = obj.Control.scale( ...
                    userInitialGuess.signal(obj.getSystemControls) ...
                    );
                
                values.Parameter = obj.Parameter.scale( ...
                    userInitialGuess.parameter(obj.getSystemParameters) ...
                    );
            end
            initialGuess = YopNlpVariableInitializer(variables, values);
        end
        
    end
    
    methods % Scaling        
        
        function scale(obj, varargin)
            
            ip = inputParser;
            ip.FunctionName = 'scale';
            ip.PartialMatching = false;
            ip.KeepUnmatched = true;
            ip.CaseSensitive = true;
            
            ip.addParameter('objective', []);
            ip.addParameter('variable', []);
            ip.addParameter('weight', []);
            ip.addParameter('shift', []);
            
            ip.parse(varargin{:})

            if ~isempty(ip.Results.variable)
                scaling(length(ip.Results.variable),1) = YopScaling;
                scaling.setVariable(ip.Results.variable);
            end

            if ~isempty(ip.Results.weight)
                scaling.setWeight(ip.Results.weight);
            end
            
            if ~isempty(ip.Results.shift)
                scaling.setOffset(ip.Results.shift);
            end
            
            if ~isempty(ip.Results.variable)
                obj.Scaling = [obj.Scaling; scaling];
            end
            
            if ~isempty(ip.Results.objective)
                obj.Objective.Weight = ip.Results.objective;
            end            
            
        end
        
        function mapScaling(obj)
            variables = [obj.Independent; obj.State; obj.Algebraic; obj.Control; obj.Parameter];
            for k=1:length(variables)
                variable = variables(k);
                
                for n=1:length(obj.Scaling)
                    scaling = obj.Scaling(n);
                    
                    if scaling.mapsTo(variable.Variable)
                        variable.setWeight(scaling.Weight);
                        variable.setOffset(scaling.Offset);
                        break;
                    end
                end                
            end
        end
        
        function input = getDescaledInput(obj)
            input = {...
                obj.Independent.descale(YopIndependentVariable.getIndependentVariable), ...
                obj.State.descale(obj.getSystemStates), ...
                obj.Algebraic.descale(obj.getSystemAlgebraics), ...
                obj.Control.descale(obj.getSystemControls), ...
                obj.Parameter.descale(obj.getSystemParameters) ...
                };
        end
        
        function scalingFunction = getDescaling(obj)
            scalingFunction = casadi.Function('descaling', ...
                obj.getInput, {obj.getDescaledInput{:}});
        end
        
    end
    
    methods % NLP interface functions
        
        function setObjective(obj)
            mayer = casadi.Function('E', obj.getInput, {obj.Objective.getMayer});
            mayerScaled = obj.Objective.Weight .* mayer(obj.getDescaledInput{:});
            obj.MayerTerm = casadi.Function('E', obj.getInput, {mayerScaled});
            
            lagrange = casadi.Function('L', obj.getInput, {obj.Objective.getLagrange});
            lagrangeScaled = obj.Objective.Weight .* lagrange(obj.getDescaledInput{:});
            obj.LagrangeTerm = casadi.Function('L', obj.getInput, {lagrangeScaled});
        end
        
        function setDifferentialEquation(obj)
            ode = casadi.Function('ode', obj.getInput, {obj.getSystemDifferentialEquation});
            odeScaled = obj.State.getWeight .* ode(obj.getDescaledInput{:});
            obj.DifferentialEquation = casadi.Function('odeS', obj.getInput, {odeScaled});
        end
        
        function setAlgebraicEquation(obj)
            obj.AlgebraicEquation = ...
                casadi.Function('alg', obj.getInput, {obj.getSystemAlgebraicEquation});
        end
        
        function l = getLagrange(obj, t, x, z, u, p)   
            l = obj.LagrangeTerm(t, x, z, u, p);
        end
        
        function e = getMayer(obj, t, x, z, u, p)
            e = obj.MayerTerm(t, x, z, u, p);
        end
        
        function odeScaled = getDifferentialEquation(obj, t, x, z, u, p)   
            odeScaled = obj.DifferentialEquation(t, x, z, u, p);         
        end
        
        function alg = getAlgebraicEquation(obj, t, x, z, u, p)
            alg = obj.AlgebraicEquation(t, x, z, u, p);
        end
        
        function t_max = getIndependentInitialUpperBound(obj)
            t_max = obj.Independent.getInitialUpperScaled(0);
        end
        
        function t_min = getIndependentInitialLowerBound(obj)
            t_min = obj.Independent.getInitialLowerScaled(0);
        end
        
        function t_max = getIndependentFinalUpperBound(obj)
            t_max = obj.Independent.getFinalUpperScaled(inf);
        end
        
        function t_min = getIndependentFinalLowerBound(obj)
            t_min = obj.Independent.getFinalLowerScaled(0);
        end
        
        function x_max = getStateUpperBound(obj)
            x_max = obj.State.getUpperScaled(inf);
        end
        
        function x_min = getStateLowerBound(obj)
            x_min = obj.State.getLowerScaled(-inf);
        end
        
        function x_max = getStateInitialUpperBound(obj)
            x_max = obj.State.getInitialUpperScaled(inf);
        end
        
        function x_min = getStateInitialLowerBound(obj)
            x_min = obj.State.getInitialLowerScaled(-inf);
        end
        
        function x_max = getStateFinalUpperBound(obj)
            x_max = obj.State.getFinalUpperScaled(inf);
        end
        
        function x_min = getStateFinalLowerBound(obj)
            x_min = obj.State.getFinalLowerScaled(-inf);
        end
        
        function z_max = getAlgebraicUpperBound(obj)
            z_max = obj.Algebraic.getUpperScaled(inf);
        end
        
        function z_min = getAlgebraicLowerBound(obj)
            z_min = obj.Algebraic.getLowerScaled(-inf);
        end
        
        function u_max = getControlUpperBound(obj)
            u_max = obj.Control.getUpperScaled(inf);
        end
        
        function u_min = getControlLowerBound(obj)
            u_min = obj.Control.getLowerScaled(-inf);
        end
        
        function u_max = getControlInitialUpperBound(obj)
            u_max = obj.Control.getInitialUpperScaled(inf);
        end
        
        function u_min = getControlInitialLowerBound(obj)
            u_min = obj.Control.getInitialLowerScaled(-inf);
        end
        
        function u_max = getControlFinalUpperBound(obj)
            u_max = obj.Control.getFinalUpperScaled(inf);
        end
        
        function u_min = getControlFinalLowerBound(obj)
            u_min = obj.Control.getFinalLowerScaled(-inf);
        end
        
        function p_max = getParameterUpperBound(obj)
            p_max = obj.Parameter.getUpperScaled(inf);
        end
        
        function p_min = getParameterLowerBound(obj)
            p_min = obj.Parameter.getLowerScaled(-inf);
        end
        
        function gi = getInitial(obj, t, x, z, u, p)
            gi = [];
            if ~isempty(obj.Initial)
                gi = obj.Initial.evaluate(obj.getInput, obj.getDescaling, t, x, z, u, p);
            end
        end
        
        function gi = getInitialUpperBound(obj)
            gi = [];
            if ~isempty(obj.Initial)
                gi = obj.Initial.getUpper;
            end
        end
        
        function gi = getInitialLowerBound(obj)
            gi = [];
            if ~isempty(obj.Initial)
                gi = obj.Initial.getLower;
            end
        end
        
        function gf = getFinal(obj, t, x, z, u, p)
            gf = [];
            if ~isempty(obj.Final)
                gf = obj.Final.evaluate(obj.getInput, obj.getDescaling, t, x, z, u, p);
            end
        end
        
        function gf = getFinalUpperBound(obj)
            gf = [];
            if ~isempty(obj.Final)
                gf = obj.Final.getUpper;
            end
        end
        
        function gf = getFinalLowerBound(obj)
            gf = [];
            if ~isempty(obj.Final)
                gf = obj.Final.getLower;
            end
        end
        
        function g = getPath(obj, t, x, z, u, p)
            g = [];
            if ~isempty(obj.Path)
                g = obj.Path.evaluate(obj.getInput, obj.getDescaling, t, x, z, u, p);
            end
        end
        
        function g = getPathUpperBound(obj)
            g = [];
            if ~isempty(obj.Path)
                g = obj.Path.getUpper;
            end
        end
        
        function g = getPathLowerBound(obj)
            g = [];
            if ~isempty(obj.Path)
                g = obj.Path.getLower;
            end
        end
        
        function gs = getStrictPath(obj, t, x, z, u, p)
            gs = [];
            if ~isempty(obj.PathStrict)
                gs = obj.PathStrict.evaluate(obj.getInput, obj.getDescaling, t, x, z, u, p);
            end
        end
        
        function gs = getStrictPathUpperBound(obj)
            gs = [];
            if ~isempty(obj.PathStrict)
                gs = obj.PathStrict.getUpper;
            end
        end
        
        function gs = getStrictPathLowerBound(obj)
            gs = [];
            if ~isempty(obj.PathStrict)
                gs = obj.PathStrict.getLower;
            end
        end        
        
    end    
end
















