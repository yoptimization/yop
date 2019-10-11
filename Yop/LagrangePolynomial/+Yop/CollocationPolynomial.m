classdef CollocationPolynomial < Yop.LagrangePolynomial
    properties
        Range
        StepCompensation = 1
    end
    
    methods
        
        function obj = CollocationPolynomial(coefficients, points, degree, range)
            collocationPoints = ...
                Yop.CollocationPolynomial.collocationPoints(points, degree);
            obj@Yop.LagrangePolynomial(collocationPoints, coefficients)
            obj.Range = range;
        end
        
        function value = evaluate(obj, tau)
            value = obj.evaluate@Yop.LagrangePolynomial(tau) ...
                .* obj.StepCompensation;
        end
        
        function polynomial = integrate(obj)
            polynomial = obj.integrate@Yop.LagrangePolynomial();
            polynomial.StepCompensation = obj.StepCompensation*obj.h;
        end
        
        function polynomial = differentiate(obj)
            polynomial = obj.differentiate@Yop.LagrangePolynomial();
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
        function tau = collocationPoints(points, degree)
            if degree >= 1
                folder = fileparts( mfilename('fullpath') );
                cp = load([folder '/collocationPoints.mat']);
                tau = cp.collocationPoints.(points){degree};               
            else
                tau = 0;
            end
        end
    end
    
end