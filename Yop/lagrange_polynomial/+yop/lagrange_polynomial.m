classdef lagrange_polynomial < handle & matlab.mixin.Copyable
    % LAGRANGE_POLYNOMIAL A class for creating and using Lagrange
    % polynomials.
    %    The class implements basic functionality for interpolating a set
    %    of values using Lagrange polynomials. The Lagrange polynomials are
    %    calculated as:
    %
    %       L(t) = sum( l_j(t)*x_j )_{j=0}^{d}
    %       l_j(t) = prod( (t - t_r)/(t_j - t_r) )_{r=0, r/=j}^{d}.
    %
    %    where L is the Lagrange polynomial, l_j the basis polynimals,
    %    t the independent variable, t_i the sampling timepoints, x_j the
    %    sampled values, and d the polynomial degree.
    %
    % -- Properties --
    %    timepoint : Row vector describing the sampling timepoints
    %
    %    value     : Matrix describing the sampling values. Must have
    %                 equally many rows as in 'timepoint'. E.g. if the
    %                 sampled signal is scalar-valued, 'value' is a row
    %                 vector.
    %
    %    basis     : Matrix containing the Lagrange basis polynomials.
    %
    % -- Methods --
    %    obj = lagrange_polynomial() : Constructor.
    %
    %    obj = init(obj, timepoints, values) : Initialization method.
    %
    %    obj = calculate_basis(obj) : Calculates the basis polynomials.
    %
    %    values = evaluate(obj, t) : Evaluate the polynomial at time t.
    %
    %    polynomial=integrate(obj,constant_term):Integrates the polynomial.
    %
    %    polynomial = differentiate(obj) : Differentiate the polynomial.
    %
    %    deg = degree(obj) : Get the polynomial degree.
    %
    % -- Examples --
    %    % COPY INTO SCRIPT
    %    % Approximate the t^2 and t^3  at the specified timepoints using a
    %    % second order Lagrange polynomial.
    %    timepoints = [1,2,3]; % Three sample points results in 2:order polynomial.
    %    analytical_values = @(t) [t.^2; t.^3];
    %    analytical_derivative = @(t) [2*t; 3*t.^2];
    %    analytical_integral = @(t) [t.^3/3; t.^4/4];
    %
    %    lp = yop.lagrange_polynomial();
    %    lp.init(timepoints, analytical_values(timepoints));
    %
    %    t = 1:0.05:3;
    %    figure(1); hold on
    %    plot(t, analytical_values(t))
    %    plot(t, lp.evaluate(t), 'x')
    %    legend('t^2', 't^3', 'lp_1', 'lp_2')
    %    title('Polynomial approximation')
    %
    %    figure(2); hold on
    %    plot(t, analytical_derivative(t))
    %    plot(t, lp.differentiate.evaluate(t), 'x')
    %    legend('2*t', '3*t.^2', 'lp_1', 'lp_2')
    %    title('differentiation')
    %
    %    figure(3); hold on
    %    plot(t, analytical_integral(t))
    %    plot(t, lp.integrate.evaluate(t), 'x')
    %    legend('1/3 t.^3', '1/4 t.^4', 'lp_1', 'lp_2')
    %    title('integration')
    %
    % -- Details --
    %    For details, see:
    %    https://en.wikipedia.org/wiki/Lagrange_polynomial
    %
    
    properties
        timepoint  % Sample timepoints
        value      % Sample values
        basis      % Polynomial basis
    end
    methods
        
        function obj = lagrange_polynomial()
            % LAGRANGE_POLYNOMIAL Class constructor
            %    Takes no arguments but requires initialization. See the
            %    lagrange_polynomial.init method for more information
            %    regarding initialization.
            %
            % -- Syntax --
            %    obj = yop.lagrange_polynomial();
            %
            % -- Examples --
            %    lp = yop.lagrange_polynomial();
        end
        
        function obj = init(obj, timepoints, values)
            % INIT Initialize the lagrange polynomial
            %    Initialize the lagrange polynomial by providing a set of
            %    timepoints and sample values. The method stores the values
            %    and calculates a basis for the Lagrange polynomial.
            %
            % -- Syntax --
            %    obj = init(obj, timepoints, values)
            %    init(obj, timepoints, values)
            %    obj.init(timepoints, values)
            %
            % -- Arguments --
            %    obj        : Handle to the Lagrange polynomial instance.
            %
            %    timepoints : Sample timepoints. Specified as a row vector.
            %
            %    values     : Sample values. Specified as a Matrix.
            %                  Must have as many columns as 'timepoints'.
            %                  Dimension of values are specified in the
            %                  column direction.
            %
            % -- Examples --
            %    % Scalar values
            %    lp = init(lp, [1,2,3], [1,4,9])
            %    init(lp, [1,2,3], [1,4,9])
            %    lp.init([1,2,3], [1,4,9])
            %
            %    % Vector valued values
            %    lp = init(lp, [1,2,3], [1,4,9; 1,8,27])
            %    init(lp, [1,2,3], [1,4,9; 1,8,27])
            %    lp.init([1,2,3], [1,4,9; 1,8,27])
            
            yop.assert(size(timepoints,1)==1, ...
                yop.messages.lagrange_polynomial_init_size_error);
            yop.assert(size(timepoints,2)==size(values,2), ...
                yop.messages.lagrange_polynomial_init_size_error);
            
            obj.timepoint = timepoints;
            obj.value = values;
            obj.calculate_basis;
        end
        
        function obj = calculate_basis(obj)
            % CALCULATE_BASIS Calculates the Lagrange polynomial basis
            %    For the given Lagrange polynomial:
            %
            %       L(t) = sum( l_j(t)*x_j )_{j=0}^{d}
            %
            %    calculates the basis l_j for all j according to:
            %
            %       l_j(t) = prod( (t - t_r)/(t_j - t_r) )_{r=0, r/=j}^{d}.
            %
            % -- Syntax --
            %    obj.calulate_basis()
            %    calculate_basis(obj)
            %
            % -- Arguments --
            %    obj : Handle to the Lagrange polynomial instance.
            
            l = zeros(obj.degree+1, obj.degree+1);
            for j=1:obj.degree+1
                l_j = 1;
                for r=1:obj.degree+1
                    if j~=r
                        Pi_r = [1 -obj.timepoint(r)] / ...
                            (obj.timepoint(j)-obj.timepoint(r));
                        l_j = conv(l_j, Pi_r);
                    end
                end
                l(j,:) = l_j;
            end
            obj.basis = l;
        end
        
        function values = evaluate(obj, t)
            % EVALUATE Evaluates the polynomial at time t
            %    Evaluate the polynomial at time t, by evaluating the
            %    Lagrange polynomial:
            %
            %       L(t) = sum( l_j(t)*x_j )_{j=0}^{d}
            %
            %    If t is a vector, it evaluates the polynomial at all
            %    timepoints.
            %
            % -- Syntax --
            %    obj.evaluate(t)
            %    evaluate(obj, t)
            %
            % -- Arguments --
            %    obj : Handle to the Lagrange polynomial instance.
            %
            %    t   : Vector with the timepoints the polynomial should be
            %           evaluated at.
            %
            % -- Examples --
            %    lp.evaluate(1);
            %    lp.evaluate(0:0.1:1);
            %    evaluate(lp, 2);
            %    evaluate(lp, 1:10);
            
            values = [];
            for n=1:length(t)
                v = 0;
                for j=1:obj.degree+1
                    v = v + polyval(obj.basis(j,:), t(n)) .* obj.value(:,j);
                end
                values = [values, v];
            end
        end
        
        function polynomial = integrate(obj, constant_term)
            % INTEGRATE Integrates the Lagrange polynomial
            %    Integrates the Lagrange polynomial with an optional
            %    constant term. Returns a new lagrange polynomial that
            %    is the integration of the input.
            %
            % -- Syntax --
            %    polynomial = integrate(obj, constant_term)
            %    polynomial = obj.integrate(constant_term)
            %
            % -- Arguments --
            %    obj           : Handle to the Lagrange polynomial to be
            %                     integrated.
            %
            %    polynomial    : Integration of the input polynomial
            %                     described as a new Lagrange polynomial.
            %
            % -- Arguments (Optional) --
            %    constant_term : Constant of integration, specified as a
            %                     numeric scalar. Defaults to 0.
            %
            % -- Examples --
            %    lp_int = lp.integrate(0)
            %    lp_int = integrate(lp, 0)
            
            if nargin == 1
                constant_term = 0;
            end
            
            [r, c] = size(obj.basis);
            new_basis = zeros(r, c+1);
            for k=1:r
                new_basis(k,:) = polyint(obj.basis(k,:), constant_term);
            end
            polynomial = copy(obj);
            polynomial.basis = new_basis;
        end
        
        function polynomial = differentiate(obj)
            % DIFFERENTIATE Differentiate the Lagrange polynomial
            %    Differentiates the Lagrange polynomial obj and returns a
            %    new lagrange polynomial that is the differentiated
            %    polynomial of the input.
            %
            % -- Syntax --
            %    polynomial = obj.differentiate()
            %    polynomial = differentiate(obj)
            %
            % -- Arguments --
            %    obj        : Handle to the Lagrange polynomial to be
            %                  differentiated.
            %    polynomial : Differentiation of the input polynomial
            %                  described as a new Lagrange Polynomial.
            %
            % -- Examples --
            %    lp_der = lp.differentiate()
            %    lp_der = differentiate(lp)
            
            [r, c] = size(obj.basis);
            new_basis = zeros(r, c-1);
            for k=1:r
                new_basis(k, :) = polyder(obj.basis(k, :));
            end
            polynomial = copy(obj);
            polynomial.basis = new_basis;
        end
        
        function deg = degree(obj)
            % DEGREE Get the Lagrange polynomial degree
            %
            % -- Syntax --
            %     deg = obj.degree
            %     deg = degree(obj)
            %
            % -- Arguments --
            %    obj : Handle to the Lagrange polynomial
            %    deg : The degree of the polynomial
            %
            % -- Examples --
            %    d = lp.degree
            %    d = degree(lp)
            
            deg = size(obj.timepoint, 2)-1;
        end
        
    end
end