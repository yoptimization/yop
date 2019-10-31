classdef collocation_polynomial < yop.lagrange_polynomial
    % COLLOCATION_POLYNOMIAL Lagrange polynomials used in collocation
    % methods.
    
    properties
        valid_range
        step_factor = 1
    end
    
    methods
        
        function obj = collocation_polynomial()
        end
        
        function obj = init(obj, points, degree, coefficients, valid_range)
            % init('legendre', 5, x_disc, [0, 1]);
            collocation_points = ...
                yop.collocation_polynomial.collocation_points(points, degree);
            obj.init@yop.lagrange_polynomial(collocation_points, coefficients);
            obj.valid_range = valid_range;
        end
        
        function value = evaluate(obj, tau)
            value = obj.evaluate@yop.lagrange_polynomial(tau) .* obj.step_factor;
        end
        
        function polynomial = integrate(obj)
            polynomial = obj.integrate@yop.lagrange_polynomial(0);
            polynomial.step_factor = obj.step_factor*obj.dt;
        end
        
        function polynomial = differentiate(obj)
            polynomial = obj.differentiate@yop.lagrange_polynomial();
            polynomial.step_factor = obj.step_factor/obj.dt;
        end
        
        function stepSize = dt(obj)           
            stepSize = diff(obj.valid_range);
        end
        
        function t = t0(obj)
            t = obj.valid_range(1);
        end
        
        function t = tf(obj)
            t = obj.valid_range(2);
        end
        
    end
    
    methods (Static)        
        function tau = collocation_points(points, degree)
            if degree >= 1
                folder = fileparts( mfilename('fullpath') );
                cp = load([folder '/collocation_points.mat']);
                tau = cp.collocation_points.(points){degree};               
            else
                tau = 0;
            end
        end
    end
    
end