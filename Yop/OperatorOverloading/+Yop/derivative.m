function y = derivative(x)
if isa(x, 'Yop.Expression') || isa(x, 'Yop.ComputationalGraph')
    y = x.derivative;
else
    y = x;
end