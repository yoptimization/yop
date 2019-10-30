classdef collocated_signal < yop.collocation_polynomial
    methods
        function obj = collocated_signal(coefficients, points, degree, valid_range)
            obj@yop.collocation_polynomial(coefficients, points, degree, valid_range);
        end
        
        function values = evaluate(obj, tau)
            values = [];
            for k=1:length(obj)
                values = [values, obj(k).evaluate@yop.collocation_polynomial(tau)];
            end
        end
        
        function values = evaluateAt(obj, time)
            values = [];
            for n=1:length(time)
                for k=1:length(obj)
                    if obj(k).is_valid_at(time(n))
                        tau = ( time(n) - obj(k).t0 )/obj(k).h;
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
                polynomials = [polynomials, obj(k).integrate@yop.collocation_polynomial()];
            end
        end
        
        function polynomials = differentiate(obj)
            polynomials = [];
            for k=1:length(obj)
                polynomials = [polynomials, obj(k).differentiate@yop.collocation_polynomial()];
            end
        end
        
        function bool = is_valid_at(obj, time)
            bool = obj.t0-time <= min(eps(time), eps(obj.t0)) && obj.tf-time > 0;
        end
    end
end