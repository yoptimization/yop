function y = integral(x)
if isa(x, 'Yop.Expression') || isa(x, 'Yop.ComputationalGraph')
    y = x.integral;
else
    y = integral(Yop.Expression(x));
end