function z = setdiff(x, y)
check = false(1, max(max(x), max(y)));
check(x) = true;
check(y) = false;
z = x(check(x));
end