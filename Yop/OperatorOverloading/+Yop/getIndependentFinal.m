function t = getIndependentFinal()
persistent independent
if isempty(independent)
    yopCustomPropertyNames;
    independent = Yop.variable(userIndependentFinal);
end
t = independent;
end