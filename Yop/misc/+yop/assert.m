function assert(cond, msg)

if nargin == 1
    msg = 'Assertion failed.';
end

builtin('assert', cond, ['Yop: ' msg]);
end