import Yop.*

nx = 2;
nu = 1;
ts = YopVar('t');
xs1 = YopVar('x1', 1);
xs2 = YopVar('x2', 1);
xs = [xs1; xs2];
us = YopVar('u');

[ode, cart] = trolleyModel(ts, xs, us);

J = 1/2*integral(cart.acceleration^2);
% J = 1000000*t_f( xs(1)^2 + (xs(2)+1)^2 ) + 1/2*integral(cart.acceleration^2);
% j1 = 1000000*t_i( xs(1)^2, 0.3 );
% J = j1 + 1/2*integral(cart.acceleration^2);
c1 = cart.position(t0) == 0;
c2 = cart.speed(t0) == 1;
c3 = cart.position(tf) == 0;
c4 = cart.speed(tf) == 1;
c5 = cart.position <= 1/9;
c6 = 0 == t0 <= tf == 1+xs(1);

constraints = {c1, c2, c3, c4, c5, c6};

%%

t = variable('t');
x = variable('x', 2);
u = variable('u');
[ode, cart] = trolleyModel(ts, xs, us);

ocp = optimalControlProblem('states',  x, 'controls', u);

ocp.minimize( 1/2*integral(cart.acceleration^2) );

ocp.subjectTo( ...
    dot(x) == ode, ...
    cart.position(t0) == 0, ...
    cart.speed(t0) == 1, ...
    cart.position(tf) == 0, ...
    cart.speed(tf) == 1, ...
    cart.position <= 1/9, ...
    0 == t0 <= tf == 1 ...
    );

res=ocp.solve('directCollocation', 'segements', 100, 'points', 'legendre');

figure(1)
subplot(211)
res.plot(t, x(1));
subplot(212)
res.plot(t, x(2));

figure(2)
res.plot(t, u);

%%
c1nlp = c1.unnestRelations;
c1nlp.isaBox

% Vilken variabel gäller det?

% Implementera gränsen för den variabeln beroende på <=, ==, >=

%%


deg = 3;
points = 'legendre';
cp = load('YopCollocationPoints.mat');
tau = cp.collocationPoints.(points){deg};

t0 = 0;
tf = 1;
K = 20;
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
    xk = x(k).evaluate(tau(2:end));
    dxk = x(k).differentiate.evaluate(tau(2:end));
    uk = u(k).evaluate(tau(2:end));
    
    if k==1                
        dxConstraint = dxFun(xk, uk) - dxk;
        
    else
        dxConstraint = [dxConstraint, dxFun(xk, uk) - dxk];
        
    end
end

% Continuity
continuity = x(1:K).evaluate(1) - x(2:end).evaluate(0);

% Objective
Jdisc = copy(J);
Jargs = Jdisc.getInputArguments;

for n=1:length(Jargs)
    if isa(Jargs{n}, 'YopIntegral')
        integrand = Jargs{n};
        integrandFunction = integrand.functionalize('L', xs, us);
        
        for k=1:K
            t = (k-1)*h;
            coefficients = [];
            for r=1:deg+1
                x_kr = x(k).evaluate(tau(r));
                u_kr = u(k).evaluate(tau(r));
                coefficients = [coefficients, integrandFunction(x_kr, u_kr)];
            end
            if k==1
                integrandPolynom = ...
                    YopCollocatedSignal(coefficients, deg, 'legendre', [t, t+h]);
            else
                integrandPolynom(k) = ...
                    YopCollocatedSignal(coefficients, deg, 'legendre', [t, t+h]);
            end
        end
        integrand.replace(integrandPolynom.integrate.evaluate(1).sum);
        
        
        % Timepoint
    elseif isequal(Jargs{n}.Timepoint, YopVar.getIndependentInitial)
        expression = Jargs{n};
        expressionFunction = expression.functionalize('e_t0', xs, us);
        x_t = x(1).evaluate(0);
        u_t = u(1).evaluate(0);
        expression.replace( expressionFunction(x_t, u_t) );
        
    elseif isequal(Jargs{n}.Timepoint, YopVar.getIndependentFinal)
        expression = Jargs{n};
        expressionFunction = expression.functionalize('e_tf', xs, us);
        x_t = x(K+1).evaluate(1);
        u_t = u(K).evaluate(1);
        expression.replace( expressionFunction(x_t, u_t) );
        
    elseif ~isempty(Jargs{n}.Timepoint)
        expression = Jargs{n};
        expressionFunction = expression.functionalize('e_ti', xs, us);
        x_t = x.evaluateAt(expression.Timepoint);
        u_t = u.evaluateAt(expression.Timepoint);
        expression.replace( expressionFunction(x_t, u_t) );
        
    elseif ~isempty(Jargs{n}.Index)
        expression = Jargs{n};
        expressionFunction = expression.functionalize('e_kr', xs, us);
        x_kr = x(expression.Index.Segment).evaluate(tau(expression.Index.CollocationPoint));
        u_kr = u(expression.Index.Segment).evaluate(tau(expression.Index.CollocationPoint));
        expression.replace( expressionFunction(x_kr, u_kr) );
        
    end
end

% Constraints
state = xs;
control = us;

for n=1:length(constraints)
    c_n = constraints(n).unnestRelations;
    for k=1:length(c_n)
        if c_n(k).isaBox
            if c_n(k).dependsOn(state)
                
            elseif c_n(k).dependsOn(control)
                
            end
            
        else
            c_nk_nlp = c_n(k).setToNlpForm;
            % Arbitrary constraint, including integral och derivative
            
        end
    end
end


%%

% Jdisc.evaluate

% Variable bounds
% x.getCoefficients

% w = [];
% for k=1:K
%     w = [w; x(k).getCoefficientVector; u(k).getCoefficientVector];
% end
% w = [w; x(K+1).getCoefficientVector];

wx = x.getCoefficientVector;
wu = u.getCoefficientVector;

lbx = -inf(size(wx));
ubx =  inf(size(wx));
ubx(1:2:end) = 1/9;
lbx(1:2) = [0; 1];
ubx(1:2) = [0; 1];
lbx(end-1:end) = [0; -1];
ubx(end-1:end) = [0; -1];

lbu = -inf(size(wu));
ubu =  inf(size(wu));

w = [wx; wu];
lb = [lbx; lbu];
ub = [ubx; ubu];

g = [dxConstraint(:).evaluate; continuity(:).evaluate];
glb = zeros(size(g));
gub = zeros(size(g));

nlp = struct;
nlp.x = w.evaluate;
nlp.f = Jdisc.evaluate;
nlp.g = g;
solver = casadi.nlpsol('S', 'ipopt', nlp);
solution = solver('x0', zeros(size(w)), 'lbx', lb, 'ubx', ub, 'lbg', glb, 'ubg', gub);

%%
w = full(solution.x);

x1_opt = w(1:((deg+1)*2):K*nx*(deg+1)+nx);
x2_opt = w(2:((deg+1)*2):K*nx*(deg+1)+nx);
u_opt = w(K*nx*(deg+1)+nx+1:end);
u_opt(end+1) = u_opt(end);

figure(1); 
subplot(311); hold on;
plot(linspace(0,1,K+1), x1_opt)
subplot(312); hold on;
plot(linspace(0,1,K+1), x2_opt)
subplot(313); hold on;
stairs(linspace(0,1,K+1), u_opt)










