dim_v = 2;
v_expr = 0;
degree = 5;
points = 'legendre';

cp = [0 casadi.collocation_points(degree, points)];

tau = casadi.MX.sym('tau');
c_v = casadi.MX.sym('v', dim_v, degree+1); % Coefficienterna
for j=1:degree+1
    Lj = 1;
    for r=1:degree+1
        if j ~= r
            Lj = Lj * (tau-cp(r))/(cp(j) - cp(r));
        end
    end
    v_expr = v_expr + Lj*c_v(:,j);
end

v_t =  casadi.Function('v_t', {tau, c_v}, {v_expr});

x_num = repmat(1:degree+1, dim_v, 1);
v_t(0.55, x_num)

%% Construct the polynomial basis

Lj = 1;
for r=1:degree+1
    if j ~= r
        Lj = Lj * (tau-cp(r))/(cp(j) - cp(r));
    end
end


%%


cc = YopCollocationCoefficients(degree, 'legendre');