function obj = convert(x)
if ~isa(x, 'Yop.Variable')|| ~isa(x, 'Yop.ComputationalGraph')
    obj = Yop.Variable(x);
end
end