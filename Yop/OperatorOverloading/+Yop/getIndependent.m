function t = getIndependent()
persistent independent
if isempty(independent)
    yopCustomPropertyNames;
    independent = Yop.variable(userIndependentVariableProperty);
end
t = independent;
end