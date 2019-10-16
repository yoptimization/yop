function assert(cond, varargin)

persistent ip
if isempty(ip)
    ip = inputParser;
    ip.FunctionName = 'yop.assert';
    ip.PartialMatching = false;
    ip.CaseSensitive = true;
    ip.addOptional('msg', 'Assertion failed.', @(x) true);
end
ip.parse(varargin{:});

builtin('assert', cond, ['Yop: ' ip.Results.msg]);
end