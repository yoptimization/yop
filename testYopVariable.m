evals = 10000;
for l=1:length(evals)
    t = tic;
    n = yop.variable('v0', 1, 1);
    for k=1:evals(l)
        v = yop.variable('vk', 1, 1);
        n = n + v;
    end
    toc(t)
end

% plot(evals, time)

% v1.set_value(1);
% v2.set_value(1);
% v3.set_value(1);
% v4.set_value(1);
% v5.set_value(1);
% v6.set_value(1);

% n1.forward;
% n2.forward
% n2_.forward
