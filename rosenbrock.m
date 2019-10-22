x = yop.variable('x',2,1);
x0 = yop.constant('x0',2,1);
A = yop.constant('A',1,2);
b = yop.constant('b');

x1 = x(1);
x2 = x(2);

f = 100*(x2-x1^2)^2 + (1-x1)^2;
c = A*x <= b;

x0.value = [-1,2];
A.value = [1,2];
b.value = 1;

