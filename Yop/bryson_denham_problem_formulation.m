yop.debug(true);
yop.options.set_symbolics('symbolic math');
% yop.options.set_symbolics('casadi');

t_0 = yop.parameter('t0');
t_f = yop.parameter('tf');
t = yop.variable('t');
x = yop.variable('x', [2,1]);
u = yop.variable('u');
l = yop.constant('l');
l.value = 1/9;

[~, cart] = trolleyModel(t, x, u);

J = 1/2*integral( u^2 ) + 1*(cart.position.t0-0)^2 + 1*(cart.position.t(0.5)-l)^2 + 1*(cart.position.tf-0)^2;
c0 = der(x) == trolleyModel(t, x, u);
c1 = 0 == t_0 <= t_f == 1;
c2 = 0 == cart.position.t0 == cart.position.tf;
c3 = 1 == cart.speed.t0 == -cart.speed.tf;
c4 = cart.position <= l;

user_constraints = {c0, c1, c2, c3, c4};

%% Objective
% Decompose into computable parts
% hitta: t0, ti, tf, integral, integrate, differentiate
%  de som inte faller inom kategorin ska kunna utvärderas direkt.
% copy->decompose->parameterize->evaluate
% Behöver kopiera allt utom variabler

[t0_list, t_list, tf_list, integral_list] = yop.node.sort(J, ...
    @(x) isequal(x.operation, @yop.t0), ...
    @(x) isequal(x.operation, @yop.t), ...
    @(x) isequal(x.operation, @yop.tf), ...
    @(x) isequal(x.operation, @yop.integral) ...
    );

% Loopa över cell arrayen istället och bena ut noderna.
constraints = yop.node_list().add_array(user_constraints);
[dynamics, box_and_path] = constraints.sort("first", ...
    @yop.dynamic_optimization.dynamics, ...
    @(x) true ...
    );











