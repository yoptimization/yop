deg = 3;
points = 'radau';
tau = [0 casadi.collocation_points(deg, points)];
%%

pf = YopPolynomialFactory(deg, points);
L = pf.calculatePolynomialBasis;
D = pf.valueAt(pf.CollocationPoints(4));

%%

cc = YopCollocationCoefficients(deg, points);
cc.L

%%
c = 1:deg+1;
c = [c; c];
x = YopCollocationPolynomial(c, deg, points, [0, 1])

%%
nx = 2;

t0 = 0;
tf = 1;
K = 10;
h = (tf-t0)/K;
label = @(symbol, k, r) [symbol '_(' num2str(k) ',' num2str(r) ')'];

t = 0;
x = YopCollocatedVariable(@(r) label('x', 1, r), nx, deg, points, [0, h]);
for k=1:K+1
    t = (k-1)*h;
    if k==1
        x = YopCollocatedVariable(@(r) label('x', k, r), nx, deg, points, [t, t+h]);
    
    elseif k == K+1
        x(k) = YopCollocatedVariable(@(r) label('x', k, r), nx, 0, points, [t, t]);
        
    else
        x(k) = YopCollocatedVariable(@(r) label('x', k, r), nx, deg, points, [t, t+h]);
        
    end
end


%% 