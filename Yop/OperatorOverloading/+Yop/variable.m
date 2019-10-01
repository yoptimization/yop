function v = variable(varargin)
persistent ip
if isempty(ip)
    ip = inputParser;
    ip.FunctionName = 'Yop.Expression.variable';
    ip.PartialMatching = false;
    ip.CaseSensitive = true;
    ip.addOptional('symbol', 'v', @(x) true);
    ip.addOptional('rows', 1, @(x) true);
    ip.addOptional('columns', 1, @(x) true);
end
ip.parse(varargin{:});

v = Yop.Expression(casadi.MX.sym( ...
    ip.Results.symbol, ...
    ip.Results.rows, ...
    ip.Results.columns ...
    ));
end