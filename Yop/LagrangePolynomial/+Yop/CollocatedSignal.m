classdef CollocatedSignal < Yop.CollocationPolynomial
    methods
        function obj = CollocatedSignal(coefficients, points, degree, range)
            obj@Yop.CollocationPolynomial(coefficients, points, degree, range);
        end
        
        function values = evaluate(obj, tau)
            values = [];
            for k=1:length(obj)
                values = [values, ...
                    obj(k).evaluate@Yop.CollocationPolynomial(tau)];
            end
        end
        
        function values = evaluateAt(obj, time)
            values = [];
            for n=1:length(time)
                for k=1:length(obj)
                    if obj(k).isInRange(time(n))
                        tau = (time(n)-obj(k).t0)/obj(k).h;
                        values = [values, obj(k).evaluate(tau)];
                        
                    elseif k==length(obj) && obj(k).tf == time(n)                        
                        values = [values, obj(k).evaluate(1)];
                        
                    end
                end
            end
        end
        
        function polynomials = integrate(obj)
            polynomials = [];
            for k=1:length(obj)
                polynomials = [polynomials, ...
                    obj(k).integrate@Yop.CollocationPolynomial()];
            end
        end
        
        function polynomials = differentiate(obj)
            polynomials = [];
            for k=1:length(obj)
                polynomials = [polynomials, ...
                    obj(k).differentiate@Yop.CollocationPolynomial()];
            end
        end
        
        function bool = isInRange(obj, time)
            obj.t0
            bool = obj.t0-time <= min(eps(time),eps(obj.t0)) && obj.tf-time > 0;
        end
    end
end