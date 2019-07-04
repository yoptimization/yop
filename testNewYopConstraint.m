x = YopExpression.Variable('x');
y = YopExpression.Variable('y');
z = YopExpression.Variable('z');

% x = casadi.MX.sym('x');
% y = casadi.MX.sym('y');
% z = casadi.MX.sym('z');


c0 = x <= 1;
c1 = -1 <= x <= ((y <= 1) <= z);

% c1.relations

% Isa box constraint
% if isa(c1.leftmost, 'numeric')
