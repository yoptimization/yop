%%
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

% Problem parametrization
x0.value  = [0.5; 0];
A.value   = [1, 2];
b.value   = 1;
Aeq.value = [2,1];
beq.value = 1;

nlp = yop.nlp('variable', x);
nlp.minimize( 100*(x2-x1^2)^2 + (1-x1)^2 );
nlp.subject_to( A*x <= b ); %  Aeq*x == b

res = nlp.solve(x0);
full(res.x)

