%% General:
% variables, parameters, constants, placeholders:
%   variabler är tidskontinuerliga signaler
%   parameterar är konstanta värden som ska bestämmas genom optimering
%   konstanter är värden som är konstanta, men som kan behöver bestämmas
%   först precis innan en simulering eller optimering.
%   placeholders är t.ex. variabler och andra uttryck som inte kan
%   evalueras direkt.

% computationalGraphs
%   Matematiska uttryck. Består av variabler, parameterar, konstanter och
%   operationer.
% relationalGraphs
%   beskriver relationer mellan beräkningar, ex: ==, ~= <, >, <=, >=
%% Variable types
v1 = yop.variable('v1');
v2 = yop.variable('v2');

v1 + v2


