%% Lagrange polynomials
clear
syms v_1 v_2 v_3 tau_0 tau_1 tau_2 t t_0 h

f_fun = @(v) v;

coefficients = [v_1, v_2, v_3];

% Construct a model for the interpolating polynomial
degree = 2; % Polynomial degree
points = 'legendre';
roots_num = [0 casadi.collocation_points(degree, points)];
roots = [tau_0 tau_1 tau_2];

% Construct the model expression
modelExpression = 0;
tau = (t-t_0)/h;
L = [];
for j=1:degree+1
    Lj = 1;
    for r=1:degree+1
        if j ~= r
            Lj = Lj * (tau-roots(r))/(roots(j) - roots(r));
        end
    end
    L = [L, Lj];
    %     modelExpression = modelExpression + Lj*f_fun(coefficients(:,j));
end

pretty(L)
%% Evaluate polynomial numerically

% tau = (t-t_k)/h_k;
tau = 0.3;
tau_0 = roots_num(1);
tau_1 = roots_num(2);
tau_2 = roots_num(3);
v_1 = 1;
v_2 = 2;
v_3 = 3;
% double(subs(modelExpression))

%% Differetiate w.r.t tau and evaluate derivative
syms tau v_1 v_2 v_3 tau_0 tau_1 tau_2 t t_k h_k
dx = jacobian(modelExpression, tau);

tau = (t-t_k)/h_k;
% tau = 0.3;
% tau_0 = roots_num(1);
% tau_1 = roots_num(2);
% tau_2 = roots_num(3);
% v_1 = 1;
% v_2 = 2;
% v_3 = 3;
subs(dx)


%%
double(subs(modelExpression))






