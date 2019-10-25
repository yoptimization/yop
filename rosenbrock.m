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
box1 = 0 <= x1 <= 1;
box2 = 1 <= x2 <= 2;
c = A*x <= b;
ceq = Aeq*x == b;

%% Vill kunna skriva
c.split.isa_box;
% behöver ändra list-klassen.

%%
x0.value = [0.5; 0];
A.value = [1, 2];
b.value = 1;
Aeq.value = [2,1];
beq.value = 1;

%% ipopt

eq = ceq.nlp_form.left.evaluate;
neq = c.nlp_form.left.evaluate;

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






