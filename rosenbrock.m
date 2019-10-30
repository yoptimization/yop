%% https://se.mathworks.com/help/optim/ug/fmincon.html#d117e83832
clear;
import yop.*
x   = variable('x', [2, 1]);
x1 = x(1);
x2 = x(2);

% Problem parametrization
x0  = [0.5; 0];
A   = [1, 2];
b   = 1;

problem = nlp('variable', x);
problem.minimize(  100*( x2 - x1^2 )^2 + ( 1 - x1 )^2  );
problem.subject_to( A*x <= b );

res = problem.solve(x0)  % [0.5022,  0.2489]
%%
clear;
import yop.*
x  = variable('x', [2, 1]);
x1 = x(1);
x2 = x(2);

% Problem parametrization
x0  = [0.5; 0];
A   = [1, 2];
Aeq = [2,1];
b   = 1;

problem = nlp('variable', x);
problem.minimize(  100*( x2 - x1^2 )^2 + ( 1 - x1 )^2  );
problem.subject_to( A*x <= b, Aeq*x == b); %  

res = problem.solve(x0)  % % [0.4149, 0.1701]

%% Bound constraints
clear;
import yop.*
x  = variable('x', [2, 1]);
x1 = x(1);
x2 = x(2);

problem = nlp('variable', x);
problem.minimize(  1 + x1/(1 + x2) - 3*x1*x2 + x2*(1 + x1)  )
problem.subject_to( 0 <= x1 <= 1,  0 <= x2 <= 2);

x0 = [0.5; 1];
res = problem.solve(x0) % [1, 2]

%% Nonlinear constraints
clear;
yop.debug(true);
import yop.*
x   = variable('x', [2, 1]);
x1 = x(1);
x2 = x(2);

problem = nlp('variable', x);
problem.minimize( 100*( x2 - x1^2 )^2 + ( 1 - x1 )^2  );
problem.subject_to( ...
    0   <= x1 <= 0.5, ...
    0.2 <= x2 <= 0.8, ...
    (x1-1/3)^2 + (x2-1/3)^2 <= (1/3)^2 ...
    );

x0 = [1/4; 1/4];
res = problem.solve(x0) % [0.5000, 0.2500]
%%
problem = yop.nlp('find', x);
problem.minimize( f(x) )
problem.subject_to( );
problem.solve();

%% fmincon

f_object = casadi.Function('objective', {x.evaluate}, {f.evaluate});
fun = @(x) full(f_object(x));
x_opt = fmincon(fun, x0.evaluate, A.evaluate, b.evaluate, Aeq.evaluate, beq.evaluate);






