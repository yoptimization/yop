%% https://se.mathworks.com/help/optim/ug/fmincon.html#d117e83832
clear;
yop.debug(true);
x   = yop.variable('x', [2, 1]);
x0  = yop.constant('x0', [2, 1]);
A   = yop.constant('A', [1, 2]);
b   = yop.constant('b');
Aeq = yop.constant('Aeq', [1, 2]);
beq = yop.constant('beq');

x1 = x(1);
x2 = x(2);

% Problem formulation
f = 100*(x2-x1^2)^2 + (1-x1)^2;
c = A*x <= b;
ceq = Aeq*x == b;

% Problem parametrization
x0.value  = [0.5; 0];
A.value   = [1, 2];
b.value   = 1;
Aeq.value = [2,1];
beq.value = 1;

% user_constraints = {c}; % [0.5022,  0.2489]
user_constraints = {c, ceq}; % [0.4149, 0.1701]

% Target code
% A.value   = [1, 2];
% b.value   = 1;
% Aeq.value = [2,1];
% beq.value = 1;
% nlp = yop.nlp('variable', x);
% nlp.minimize( 100*(x2-x1^2)^2 + (1-x1)^2 );
% nlp.subject_to( A*x <= b, Aeq*x == b );
% res = nlp.solve('solver', 'ipopt');
%% Bound constraints
clear;
yop.debug(true);
x0  = yop.constant('x0', [2, 1]);
x   = yop.variable('x', [2, 1]);
x1 = x(1);
x2 = x(2);

f = 1+x1/(1+x2) - 3*x1*x2 + x2*(1+x1);
box1 = 0 <= x1 <= 1;
box2 = 0 <= x2 <= 2;

user_constraints = {box1, box2};
x0.value = [0.5; 1];

%% Nonlinear constraints
clear;
yop.debug(true);
x0  = yop.constant('x0', [2, 1]);
x   = yop.variable('x', [2, 1]);
x1 = x(1);
x2 = x(2);

f = 100*(x2-x1^2)^2 + (1-x1)^2;
box1 = 0 <= x1 <= 0.5;
box2 = 0.2 <= x2 <= 0.8;
circle = (x1-1/3)^2 + (x2-1/3)^2 <= (1/3)^2;

user_constraints = {box1, box2, circle};
x0.value = [1/4; 1/4];

%% Parse

constraints = yop.node_list();
for k=1:length(user_constraints)
    constraints.add(user_constraints{k});
end
[box, nl_con] = constraints.split.sort(@isa_box, @(x) ~isa_box(x));

%%
con = [c.general_form.nlp_form.left; ceq.general_form.nlp_form.left; c.general_form.nlp_form.left];
%%
% Box constraints
lb = yop.node('lb', size(x));
ub =  yop.node('ub', size(x));
lb.value = -inf(size(x));
ub.value =  inf(size(x));

for k=1:length(box)
    
    if box.object(k).isa_upper_type1
        ub(box.object(k).left.get_indices) = box.object(k).right;
        
    elseif box.object(k).isa_upper_type2
        ub(box.object(k).right.get_indices) = box.object(k).left;
        
    elseif box.object(k).isa_lower_type1
        lb(box.object(k).left.get_indices) = box.object(k).right;
        
    elseif box.object(k).isa_lower_type2
        lb(box.object(k).right.get_indices) = box.object(k).left;
        
    elseif box.object(k).isa_equality_type1
        ub(box.object(k).left.get_indices) = box.object(k).right;
        lb(box.object(k).left.get_indices) = box.object(k).right;
        
    elseif box.object(k).isa_equality_type2
        ub(box.object(k).right.get_indices) = box.object(k).left;
        lb(box.object(k).right.get_indices) = box.object(k).left;
        
    end
end

% Nonlinear constraints
[eq, neq] = nl_con.general_form.nlp_form.sort(@(x)isequal(x.relation, @eq), @(x)isequal(x.relation, @le));


%% ipopt

g = eq.left.evaluate;
h = neq.left.evaluate;

nlp = struct;
nlp.x = x.evaluate;
nlp.f = f.evaluate;
nlp.g = [g; h];

%%
optimizer = casadi.nlpsol('yoptimizer', 'ipopt', nlp);
res = optimizer( ...
    'x0', x0.evaluate, ...
    'ubx', ub.evaluate, ...
    'lbx', lb.evaluate, ...
    'ubg', [zeros(size(g)); zeros(size(h))], ...
    'lbg', [zeros(size(g)); -inf(size(h))]);
full(res.x)

%% fmincon

f_object = casadi.Function('objective', {x.evaluate}, {f.evaluate});
fun = @(x) full(f_object(x));
x_opt = fmincon(fun, x0.evaluate, A.evaluate, b.evaluate, Aeq.evaluate, beq.evaluate);






