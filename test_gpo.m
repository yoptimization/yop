syms x1 x2 x3 x4

%%
v1 = yop.variable('v1');
v2 = yop.variable('v2');
v3 = yop.variable('v3');
v4 = yop.variable('v4');

n1 = v1 + v2;
n2 = v1 + v3;
n3 = n1 + n2;
n4 = n3 + n2;
n5 = n4 + v4;

%%
v1.set_value(x1);
v2.set_value(x2);
v3.set_value(x3);
v4.set_value(x4);

%%
n5.evaluate()
