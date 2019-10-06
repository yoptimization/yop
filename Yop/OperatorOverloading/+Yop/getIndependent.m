function t = getIndependent()
persistent independent
if isempty(independent)
    yopCustomPropertyNames;
    independent = Yop.YopVar(userIndependentVariableProperty);
end
t = independent;
end