%% https://se.mathworks.com/help/optim/ug/fmincon.html#d117e83832
x = yop.variable('x',2,1);
x0 = yop.constant('x0',2,1);
A = yop.constant('A',1,2);
b = yop.constant('b');
Aeq = yop.constant('Aeq',1,2);
beq = yop.constant('beq');

x1 = x(1);
x2 = x(2);

f = 100*(x2-x1^2)^2 + (1-x1)^2;
box1 = 0 <= x1 <= 1 <= x2 <= 2;
% box2 = 1 <= x2 <= 2;
c = A*x <= b;
ceq = Aeq*x == b;

%%
x0.value = [0.5; 0];
A.value = [1, 2];
b.value = 1;
Aeq.value = [2,1];
beq.value = 1;

%% Parse

% user_constraints = {box1, box2, c, ceq};
user_constraints = {box1, c, ceq};
constraints = yop.node_list();
for k=1:length(user_constraints)
    constraints.add(user_constraints{k});
end
[box, nl_con] = constraints.split.sort(@isa_box, @(x) ~isa_box(x));
[eq, neq] = nl_con.general_form.nlp_form.sort(@(x)isequal(x.relation, @eq), @(x)isequal(x.relation, @le));

%% ipopt
% -------------
% constraints - cell array
%               constraints{k}.split.sort(@isa_box, @(x) is_valid(x) && ~isa_box(x));
% [box, nl_con] = constraints.split.sort(@isa_box, @is_valid);

nlp_variables.map(box);


[eq, neq] = nl_con.general_form.nlp_form.left.evaluate;
% -------------

eq = ceq.general_form.nlp_form.left.evaluate;
neq = c.general_form.nlp_form.left.evaluate;

nlp = struct;
nlp.x = x.evaluate;
nlp.f = f.evaluate;
nlp.g = [eq; neq];
optimizer = casadi.nlpsol('optimizer', 'ipopt', nlp);
res = optimizer( ...
    'x0', x0.evaluate, ...
    'ubg', [zeros(size(eq)); zeros(size(neq))], ...
    'lbg', [zeros(size(eq)); -inf(size(neq))]);
full(res.x)

%% fmincon

f_object = casadi.Function('objective', {x.evaluate}, {f.evaluate});
fun = @(x) full(f_object(x));
x_opt = fmincon(fun, x0.evaluate, A.evaluate, b.evaluate, Aeq.evaluate, beq.evaluate);






