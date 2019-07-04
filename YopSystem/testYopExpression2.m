rows = 3;
columns = 3;
rowIndex = 3;
columnIndex = 3;
value = 4;

x = casadi.MX.sym('x', rows, columns);
x(rowIndex, columnIndex) = value

v = YopExpression.Variable('v', rows, columns);
v(rowIndex, columnIndex) = value;
v.value

%%
rows = 3;
columns = 3;
index = [1, 3, 5];
value = 4:6;

x = casadi.MX.sym('x', rows, columns);
x(index) = value

v = YopExpression.Variable('v', rows, columns);
v(index) = value;
v.value

%%
rows = 3;
columns = 1;

x = casadi.MX.sym('x', rows, columns);
xh = [x; x]


v = YopExpression.Variable('v', rows, columns);
vh = [v; v]
vh.value

%%

a = YopExpression.Variable('a');
b = YopExpression.Variable('b');
c = YopExpression.Variable('c');

di = 1 <= b <= c
