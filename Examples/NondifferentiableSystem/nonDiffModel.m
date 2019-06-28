function dx = nonDiffModel(t, x, u)
% Nondifferentiable part
d = 100*(if_else(t > 0.5,1,0)-if_else(t > 0.6,1,0));

dx1 = x(2);
dx2 = -x(1)-x(2)+u+d;
dx3 = 5*x(1)^2+2.5*x(2)^2+0.5*u^2;
dx = [dx1;dx2;dx3];
end
