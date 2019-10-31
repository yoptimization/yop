%% https://se.mathworks.com/help/optim/ug/fmincon.html#d117e83832
% Linear inequality constraint
clear;
import yop.*
x   = variable('x', [2, 1]);
x1 = x(1);
x2 = x(2);

% Problem parametrization
x0  = [0.5; 0];
A   = [1, 2];
b   = 1;

objective = @(x) 100*( x(2) - x(1)^2 )^2 + ( 1 - x(1) )^2;

nlp = nonlinear_program('variable', x);
nlp.minimize( objective(x) );
% nlp.minimize(  100*( x2 - x1^2 )^2 + ( 1 - x1 )^2  );
nlp.subject_to( A*x <= b );

% [0.5022,  0.2489]
nlp.solve(x0)

% yop.nonlinear_program('variable', x).minimize(100*(x2-x1^2)^2+(1-x1 )^2).subject_to(A*x <= b).solve(x0);

%% Linear inequality and equality constraint
clear;
import yop.*
x  = variable('x', [2, 1]);
b  = constant('b');
x1 = x(1);
x2 = x(2);

% Problem parametrization
x0  = [0.5; 0];
A   = [1, 2];
Aeq = [2,1];
b.value = 1;

nlp = nonlinear_program('variable', x);
nlp.minimize(  100*( x2 - x1^2 )^2 + ( 1 - x1 )^2  );
nlp.subject_to( A*x <= b, Aeq*x == b ); %  

% [0.4149, 0.1701]
nlp.solve(x0)

%% Bound constraints
clear;
import yop.*
x  = variable('x', [2, 1]);
x1 = x(1);
x2 = x(2);

nlp = nonlinear_program('variable', x);
nlp.minimize(  1 + x1/(1 + x2) - 3*x1*x2 + x2*(1 + x1)  )
nlp.subject_to( 0 <= x1 <= 1,  0 <= x2 <= 2);

x0 = [0.5; 1];
% [1, 2]
nlp.solve(x0)

%% Nonlinear constraints
clear;
import yop.*
x  = variable('x', [2, 1]);
ub = constant('ub', [2, 1]);
lb = constant('lb', [2, 1]);
x1 = x(1);
x2 = x(2);

nlp = nonlinear_program('variable', x);
nlp.minimize( 100*( x2 - x1^2 )^2 + ( 1 - x1 )^2  );
nlp.subject_to( lb <= x <= ub, (x1-1/pi)^2 + (x2-1/3)^2 <= (1/3)^2 );

x0 = [1/4; 1/4];
lb.value = [0; 0.2];
ub.value = [0.5; 0.8];

% [0.5000, 0.2500]
nlp.solve(x0)
%%
nlp = yop.nonlinear_program('find', x);
nlp.minimize( f(x) )
nlp.subject_to( );
nlp.solve();

%% fmincon

f_object = casadi.Function('objective', {x.evaluate}, {f.evaluate});
fun = @(x) full(f_object(x));
x_opt = fmincon(fun, x0.evaluate, A.evaluate, b.evaluate, Aeq.evaluate, beq.evaluate);






