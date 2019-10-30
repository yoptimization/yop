classdef lagrange_polynomial < handle & matlab.mixin.Copyable
    properties
        sample
        basis
    end
    methods
        
        function obj = lagrange_polynomial(xdata, ydata)
            obj.sample.timepoint = xdata;
            obj.sample.value = ydata;
            obj.calculate_basis;
        end
        
        function calculate_basis(obj)
            L = zeros(obj.degree+1, obj.degree+1);
            for j=1:obj.degree+1
                L_j = 1;
                for r=1:obj.degree+1
                    if j~=r
                        Pi_r = [1 -obj.sample.timepoint(r)] / ...
                            (obj.sample.timepoint(j)-obj.sample.timepoint(r));
                        L_j = conv(L_j, Pi_r);
                    end
                end
                L(j,:) = L_j;
            end
            obj.basis = L;
        end
        
        function values = evaluate(obj, tau)
            values = [];
            for n=1:length(tau)
                value = 0;
                for j=1:obj.degree+1
                    value = value + ...
                       polyval(obj.basis(j,:), tau(n)) .* obj.sample.value(:,j);
                end
                values = [values, value];
            end
        end
        
        function polynomial = integrate(obj, constant_term)
            [r, c] = size(obj.basis);
            new_basis = zeros(r, c+1);
            for k=1:r
                new_basis(k,:) = polyint(obj.basis(k,:), constant_term);
            end
            polynomial = copy(obj);
            polynomial.basis = new_basis;
        end
        
        function polynomial = differentiate(obj)
            [r, c] = size(obj.basis);
            new_basis = zeros(r, c-1);
            for k=1:r
                new_basis(k, :) = polyder(obj.basis(k, :));
            end
            polynomial = copy(obj);
            polynomial.basis = new_basis;
        end
        
        function deg = degree(obj)
            c = size(obj.sample.timepoint, 2);
            deg = c-1;
        end
        
        function set_coefficients(obj, coefficients)
            obj.sample.value = coefficients;
        end
        
        function coefficients = get_coefficients(obj)
            coefficients = [];
            for k=1:length(obj)
                coefficients = [coefficients, obj(k).sample.value];
            end
        end
        
        function coefficients = get_coefficient_vector(obj)
            tmp = obj.get_coefficients;
            coefficients = tmp(:);
        end
        
    end
end