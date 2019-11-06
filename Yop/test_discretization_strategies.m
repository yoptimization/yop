%% Diskretisera genom att kontrollera value för x, u
yop.debug(true);
yop.options.set_symbolics('symbolic math');
% yop.options.set_symbolics('casadi');

t_0 = yop.parameter('t0');
t_f = yop.parameter('tf');
t = yop.variable('t');
x = yop.variable('x', [2,1]);
u = yop.variable('u');

[dx, y] = trolleyModel(t, x, u);
J_integrand = 1/2*u^2;

% Parametrisera signalerna
K = 100;
nx = 2;
nu = 1;
h = (t_f-t_0)/K;
points = 'legendre';
d_x = 5;
d_u = 0;

%%
% % state = yop.collocation_polynomial();
% % w_x = yop.variable('x', [(d_x+1)*nx, 1]);
% % idx = yop.variable('k');
% % state.init(points, d_x, reshape(w_x, nx, d_x+1), h*[(idx-1) idx]);

%%
clear state control
state(K+1) = yop.collocation_polynomial();
for k=1:K
    w_x = yop.variable(['x_' num2str(k)], [(d_x+1)*nx, 1]);
    state(k).init(points, d_x, reshape(w_x, nx, d_x+1), h*[(k-1) k]);
end
w_x = yop.variable(['x_' num2str(K+1)], [nx, 1]);
state(K+1).init(points, 0, w_x, [t_f, t_f]);


control(K) = yop.collocation_polynomial();
for k=1:K
    w_u = yop.variable(['u_' num2str(k+1)], [(d_u+1)*nu, 1]);
    control(k).init(points, d_u, reshape(w_u, nu, d_u+1), [(k-1)*h k*h]);
end

%% Styr parameterarna genom att sätta värden på t,x,z,u

% Diskretiera dynamiken på ett intervall
tau = yop.collocation_polynomial.collocation_points(points, d_x);
g_dyn = yop.list();
for k=1:K
    for d=2:d_x+1
        w_x.value = 1;
        x.value = state(k).evaluate(tau(d));
        u.value = control(k).evaluate(tau(d));
        g_dyn.add( state(k).differentiate.evaluate(tau(d)) - dx.evaluate );
    end
end

% Varje: Har samma struktur, men beräkningsordningen beräknas ändå varje
% gång, det är inte bra. En annan lösning måste göras.
%  state(k).differentiate.evaluate(tau(d)) - dx.evaluate 

% Continuity
g_cont = yop.list();
for k=1:K
    g_cont.add( state(k).evaluate(1) - state(k+1).evaluate(0) );
end

%% Objective

% Integranderna måste dela evalueringsordning! De har exakt samma struktur
% på alla intervallen, men beräknar ändå om ordningen varje gång. Måste ta
% fram en prototyp för ett segment som kan användas av alla.

% Parametrisera en signal som sedan kan integreras.
integrand(K) = yop.collocation_polynomial();
for k=1:K
    samples = [];
    for d=1:d_x+1
        x.value = state(k).evaluate(tau(d));
        u.value = control(k).evaluate(tau(d));
        samples = [samples, J_integrand.evaluate];
    end
    integrand(k).init(points, d_x, samples, [(k-1)*h k*h]);
end

%%
J_disc = 0;
for k=1:K
    J_disc = J_disc + integrand(k).integrate.evaluate(1);
end
J_disc.evaluate;









