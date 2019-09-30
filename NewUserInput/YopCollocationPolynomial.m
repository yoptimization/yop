classdef YopCollocationPolynomial < YopLagrangePolynomial
    properties
        Range
        StepCompensation = 1
    end
    
    methods
        
        function obj = YopCollocationPolynomial(coefficients, degree, points, range)
            collocationPoints = ...
                YopCollocationPolynomial.collocationPoints(degree, points);
            obj@YopLagrangePolynomial(collocationPoints, coefficients)
            obj.Range = range;
        end
        
        function value = evaluate(obj, tau)
            value = obj.evaluate@YopLagrangePolynomial(tau) ...
                .* obj.StepCompensation;
        end
        
        function polynomial = integrate(obj)
            polynomial = obj.integrate@YopLagrangePolynomial();
            polynomial.StepCompensation = obj.StepCompensation*obj.h;
        end
        
        function polynomial = differentiate(obj)
            polynomial = obj.differentiate@YopLagrangePolynomial();
            polynomial.StepCompensation = obj.StepCompensation/obj.h;
        end
        
        function stepSize = h(obj)           
            stepSize = diff(obj.Range);
        end
        
        function t = t0(obj)
            t = obj.Range(1);
        end
        
        function t = tf(obj)
            t = obj.Range(2);
        end
        
    end
    
    methods (Static)        
        function tau = collocationPoints(degree, points)
            if degree >= 1
                tau = [0 double(casadi.collocation_points(degree, points))];
            else
                tau = 0;
            end
        end
    end
    
end