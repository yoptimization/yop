t = YopVar.variable('t');
x1 = YopVar.variable('x1');
x2 = YopVar.variable('x2');
x3 = YopVar.variable('x3');
x = [x1; x2; x3];
u = YopVar.variable('u');

% t = casadi.MX.sym('t');
% x = casadi.MX.sym('x', 3, 1);
% u = casadi.MX.sym('u');

[dx, y] = goddardModel(t, x, u)
rocket = y.rocket;

%%

% t_f >= t_0;
% ddt(u) >= 0;

c1 = rocket.speed(t_0) == 0;
c10 = t_0(rocket.speed) == 0;
% c11 = box( rocket.speed(t_2) == 100 );
c2 = rocket.height(t_0) == 0;
c3 = rocket.fuelMass(t_0) == 100;
c4 = t_0(rocket.fuelMass) == 100;
c5 = 100 <= rocket.fuelMass - rocket.thrust(t_0)  <= 10;
c6 = 0 <= rocket.fuelMassFlow <= 1;
c7 = 0 <= rocket.height <= inf;
c8 = 0 <= rocket.height(t_f)^2 - rocket.height(t_0) <= rocket.speed(t_0) + rocket.fuelMass(t_f);
c9 = rocket.speed <= rocket.height == 10

% strict()

%% Vid implementation
constraints = vertcat(varargin{:});
cNlp = constraint.unnestRelations.setToNlpForm;

%% Standardformat

% ocp
% min  E(t_f, t_0) + integral( L(t) )
% s.t.
%      lb <= x,z,u,p <= ub
%      lb <= t_i(x,z,u,p) <= ub
%      g(t)   <= 0
%      g(t_i) <= 0
%      h(t)   == 0
%      h(t_i) == 0
% nlp
% min  f(x)
% s.t.
%      x_lb <= x <= x_ub
%      g(x) <= 0
%      h(x) == 0

% Dela dubbelolikheter
%
% getUpperBound
% getLowerBound
% getExpression
% isaBoxConstraint
% isaBoundaryConstraint

%% Parameterize constraints

% Utvärdera uttrycken i noderna med nya variabler. Utvärdera hela
% uttrycket. Sätt på std form. Lägg in i NLP.

u8 = c8.unnestRelations;


arg1 = u8(1).getInputArguments;







