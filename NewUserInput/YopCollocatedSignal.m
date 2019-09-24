classdef YopCollocatedSignal < YopCollocationPolynomial
    methods
        function obj = YopCollocatedSignal(coefficients, degree, points, range)
            obj@YopCollocationPolynomial(coefficients, degree, points, range);
        end
        
        function values = evaluate(obj, tau)
            values = [];
            for k=1:length(obj)
                values = [values, ...
                    obj(k).evaluate@YopCollocationPolynomial(tau)];
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
                    obj(k).integrate@YopCollocationPolynomial()];
            end
        end
        
        function polynomials = differentiate(obj)
            polynomials = [];
            for k=1:length(obj)
                polynomials = [polynomials, ...
                    obj(k).differentiate@YopCollocationPolynomial()];
            end
        end
        
        function bool = isInRange(obj, time)
            bool = obj.t0-time <= 0 && obj.tf-time > 0;
        end
    end
end