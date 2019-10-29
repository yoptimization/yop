x = yop.constant('x', [2,1]);
y = yop.constant('y', [2,1]);
z = yop.constant('z', [2,1]);

x.value = 1*[1; 1];
y.value = 2*[1; 1];
z.value = 3*[1; 1];

lb = yop.node('lb', [6,1]);
lb.value = -inf(6,1);
lb(1:2) = x;
lb(3:4) = y;
% lb(5:6) = z;
lb.evaluate()