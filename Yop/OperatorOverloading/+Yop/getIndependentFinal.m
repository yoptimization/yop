function t = getIndependentFinal()
persistent independent
if isempty(independent)
    yopCustomPropertyNames;
    independent = Yop.YopVar(userIndependentFinal);
end
t = independent;
end