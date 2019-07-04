t = YopExpression.Variable('t');
x = YopExpression.Variable('x', 3);
u = YopExpression.Variable('u');

[dx, y] = goddardModel(t, x, u)

%%
e = x <= x <= 2

%% Possible constraints combinations (NOT! included boundary constraints)

% Box constraints
e1  =  x(t) ==  1 ;
e2  =  x(t) <   1 ;
e3  =  x(t) <=  1 ;
e4  =  x(t) >  -1 ;
e5  =  x(t) >= -1 ;

% Path constraints
e6  = x(t) == g(t) ; % <-- ingen skillnad på x och f(x) för path
e7  = x(t) <  g(t) ; %    |
e8  = x(t) <= g(t) ; %    |
e9  = x(t) >  g(t) ; %    |
e10 = x(t) >= g(t) ; % <--
e11 = f(t) == g(t) ;
e12 = f(t) <  g(t) ;
e13 = f(t) <= g(t) ;
e14 = f(t) >  g(t) ;
e15 = f(t) >= g(t) ;

% Box, double inequality
e16 =  -1  <  x(t)  <   1   ;
e17 =  -1  <= x(t)  <=  1   ;
e18 =   1  >  x(t)  >  -1   ;
e19 =   1  >= x(t)  >= -1   ;

% Mixed box and path
e20 = g(t) <  x(t)  <   1   ;
e21 = g(t) <= x(t)  <=  1   ;
e22 = g(t) >  x(t)  >  -1   ;
e23 = g(t) >= x(t)  >= -1   ;
e24 =  -1  <  x(t)  <  g(t) ;
e25 =  -1  <= x(t)  <= g(t) ;
e26 =   1  >  x(t)  >  g(t) ;
e27 =   1  >= x(t)  >= g(t) ;

% Path constraints (single constraint)
e28 = g(t) <  f(t)  <  h(t) ;
e29 = g(t) <= f(t)  <= h(t) ;
e30 = g(t) >  f(t)  >  h(t) ;
e31 = g(t) >= f(t)  >= h(t) ;

% Path constraints (to be converted into two constraints)
e32 =  -1  <  f(t)  <   1 ;
e33 =  -1  <= f(t)  <=  1 ;
e34 =   1  >  f(t)  >  -1 ;
e35 =   1  >= f(t)  >= -1 ;

%% Box constraint
% Ett bivillkor är ett boxconstraint om det är numeriska värden för en
% variabel


%% OCP -> NLP Constraints

c1 = -1 <= w <= 1;








 