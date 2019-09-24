%% Lagrange polynomials

% Variables
nv = 2; % Dimension of the approximated function
v = casadi.MX.sym('v', nv);

f_expr = v;
f_fun = casadi.Function('f', {v}, {f_expr});

% Construct a model for the interpolating polynomial
degree = 3; % Polynomial degree
points = 'legendre';
roots = [0 casadi.collocation_points(degree, points)];

% Allocate polynomial coefficients
coefficients = [];
for k=1:degree+1
    coefficients = [coefficients, casadi.MX.sym(['v_' num2str(k)], nv)];
end

% Construct the model expression
t = casadi.MX.sym('t');
t_0 = casadi.MX.sym('t_0');
h = casadi.MX.sym('h');
tau = (t-t_0)/h;
modelExpression = 0;
for j=1:degree+1
    Lj = 1;
    for r=1:degree+1
        if j ~= r
            Lj = Lj * (tau-roots(r))/(roots(j) - roots(r));
        end
    end
    modelExpression = modelExpression + Lj*f_fun(coefficients(:,j));
end
model = casadi.Function('v', {tau, coefficients}, {modelExpression});

% Derivative at t
h_k = casadi.MX.sym(h_k);
for r=1:degree+1
    
end




%%
v_num = repmat(1:degree+1, dim_v, 1);
tau_num = 0.55;
full(model([0.48, 0.5], v_num))

t_num = 0:0.01:1;
plot(t_num, full(model(t_num, v_num)))


