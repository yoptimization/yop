nx = 2;
nu = 1;
ts = YopVar.variable('t');
xs = YopVar.variable('x', nx);
us = YopVar.variable('u');

[ode, cart] = trolleyModel(ts, xs, us);

J = 1/2*integral(cart.acceleration^2);
c1 = cart.position(t_0) == 0;
c2 = cart.speed(t_0) == 1;
c3 = cart.position(t_f) == 0;
c4 = cart.speed(t_f) == 1;
c5 = cart.position <= 1/9;
c6 = 0 == t_0 <= t_f == 1;

% JFun = J.function
dxFun = ode.functionalize('dx', xs, us);

%%

deg = 3;
points = 'radau';
tau = [0, casadi.collocation_points(deg, points)];

t0 = 0;
tf = 1;
K = 10;
h = (tf-t0)/K;
label = @(symbol, k, r) [symbol '_(' num2str(k) ',' num2str(r) ')'];

% State
for k=1:K+1
    t = (k-1)*h;
    if k==1
        x = YopCollocatedVariable(@(r) label('x', k, r), nx, deg, points, [t, t+h]);
    
    elseif k == K+1
        x(k) = YopCollocatedVariable(@(r) label('x', k, r), nx, 0, points, [t, t]);
        
    else
        x(k) = YopCollocatedVariable(@(r) label('x', k, r), nx, deg, points, [t, t+h]);
        
    end
end

% Control signal
for k=1:K
    t = (k-1)*h;
    if k==1
        u = YopCollocatedVariable(@(r) label('u', k, r), nu, 0, points, [t, t+h]);
        
    else
        u(k) = YopCollocatedVariable(@(r) label('u', k, r), nu, 0, points, [t, t+h]);
        
    end
end


% Dynamics
for k=1:K
    if k==1
        dxConstraint = dxFun(x(k).evaluate(tau(2:end)), u(k).evaluate(tau(2:end))) - x(k).differentiate.evaluate(tau(2:end));
    
    else
        dxConstraint = [dxConstraint, dxFun(x(k).evaluate(tau(2:end)), u(k).evaluate(tau(2:end))) - x(k).differentiate.evaluate(tau(2:end))];
        
    end
end

% Continuity
continuity = x(1:K).evaluate(1) - x(2:end).evaluate(0);

% Objective
Jdisc = copy(J);
Jargs = Jdisc.getInputArguments;
L = Jargs{2};
Lfn = L.functionalize('L', xs, us);

for k=1:K
    t = (k-1)*h;
    ck = [];    
    for r=1:deg+1
        ck = [ck, Lfn(x(k).evaluate(tau(r)), u(k).evaluate(tau(r)))];
    end    
    if k==1
        Ldisc = YopCollocatedSignal(ck, deg, 'legendre', [t, t+h]);
    else
        Ldisc(k) = YopCollocatedSignal(ck, deg, 'legendre', [t, t+h]);
    end
end

L.Value = Ldisc.integrate.evaluate(1).sum;
% Jdisc.evaluate

% Variable bounds
% x.getCoefficients






















