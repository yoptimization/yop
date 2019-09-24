classdef YopPolynomialFactory < handle
    properties
        Degree
        Coefficients
        CollocationPoints
        Basis
        Timespan % Giltigt tidsområde för polynomet
    end
    methods
        function obj = YopPolynomialFactory(degree, points)
            obj.Degree = degree;
            obj.CollocationPoints = [0 casadi.collocation_points(degree, points)];
        end        
        
        function polynomial = factory(obj, coefficients)
        end
        
        function W = valueAt(obj, tau)
            % Gör till högre ordnings-funktion
            W = zeros(obj.Degree+1, 1);
            for k=1:obj.Degree+1
                W(k) = polyval(obj.Basis(k,:), tau);
            end
        end
        
        function C = derivative(obj)
            C = zeros(obj.Degree+1, obj.Degree);
            for k=1:obj.Degree+1
                C(k,:) = polyder(obj.Basis(k,:));                
            end
            
        end
        
        function L = calculatePolynomialBasis(obj)
            tau = obj.CollocationPoints;
            L = zeros(obj.Degree+1, obj.Degree+1);           
            for j=1:obj.Degree+1
                Lj = 1; 
                for r=1:obj.Degree+1
                    if r ~= j
                        Lj = conv(Lj, [1, -tau(r)]) / ( tau(j)-tau(r) );
                    end
                end
                L(j,:) = Lj;
            end
            obj.Basis = L;
        end
        
    end
    
end