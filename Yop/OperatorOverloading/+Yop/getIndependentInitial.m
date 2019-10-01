function t = getIndependentInitial()
persistent independent
if isempty(independent)
    yopCustomPropertyNames;
    independent = Yop.variable(userIndependentInitial);
end
t = independent;
end