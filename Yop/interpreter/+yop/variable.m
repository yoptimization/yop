function v = variable(name, var_size)
if nargin == 0
    name = 'x';
    var_size = [1, 1];
elseif nargin == 1
    var_size = [1, 1];
end
v(var_size(1), var_size(2)) = yop.scalar();
for k=1:var_size(1)
    for n=1:var_size(2)
        v(k, n).init([name '_(' num2str(k) ',' num2str(n) ')'], 1, 1);
    end
end
end