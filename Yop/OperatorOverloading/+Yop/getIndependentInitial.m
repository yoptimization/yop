function t = getIndependentInitial()
persistent independent
if isempty(independent)
    yopCustomPropertyNames;
    independent = Yop.YopVar(userIndependentInitial);
end
t = independent;
end