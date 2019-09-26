classdef YopLagrangePolynomial < handle & matlab.mixin.Copyable
    properties
        Data
        Basis
    end
    methods
        
        function obj = YopLagrangePolynomial(xdata, ydata)
            obj.Data.x = xdata;
            obj.Data.y = ydata;
            obj.calculateBasis;
        end
        
        function calculateBasis(obj)
            L = zeros(obj.degree+1, obj.degree+1);
            for j=1:obj.degree+1
                Lj = 1;
                for r=1:obj.degree+1
                    if j~=r
                        Pi_r = [1 -obj.Data.x(r)]/(obj.Data.x(j)-obj.Data.x(r));
                        Lj = conv(Lj, Pi_r);
                    end
                end
                L(j,:) = Lj;
            end
            obj.Basis = L;
        end
        
        function values = evaluate(obj, tau)
            values = [];
            for n=1:length(tau)
                value = 0;
                for j=1:obj.degree+1
                    pv = polyval(obj.Basis(j,:), tau(n));
                    newValue = pv .* obj.Data.y(:,j);
                    value = value + newValue;
                    %value = value + ...
                    %    polyval(obj.Basis(j,:), tau(n)) .* obj.Data.y(:,j);
                end
                values = [values, value];
            end
        end
        
        function polynomial = integrate(obj)
            [r, c] = size(obj.Basis);
            newBasis = zeros(r, c+1);
            for k=1:r
                newBasis(k,:) = polyint(obj.Basis(k,:), 0);
            end
            polynomial = copy(obj);
            polynomial.Basis = newBasis;
        end
        
        function polynomial = differentiate(obj)
            [r, c] = size(obj.Basis);
            newBasis = zeros(r, c-1);
            for k=1:r
                newBasis(k, :) = polyder(obj.Basis(k, :));
            end
            polynomial = copy(obj);
            polynomial.Basis = newBasis;
        end
        
        function deg = degree(obj)
            c = size(obj.Data.x, 2);
            deg = c-1;
        end
        
        function setCoefficients(obj, coefficients)
            obj.Data.y = coefficients;
        end
        
        function coefficients = getCoefficients(obj)
            coefficients = obj.Data.y;
        end
    end
end