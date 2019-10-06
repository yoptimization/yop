function v = YopVar(varargin)
persistent ip
if isempty(ip)
    ip = inputParser;
    ip.FunctionName = 'Yop.YopVar';
    ip.PartialMatching = false;
    ip.CaseSensitive = true;
    ip.addOptional('symbol', 'v', @(x) true);
    ip.addOptional('rows', 1, @(x) true);
    ip.addOptional('columns', 1, @(x) true);
end
ip.parse(varargin{:});

v = Yop.Variable(casadi.MX.sym( ...
    ip.Results.symbol, ...
    ip.Results.rows, ...
    ip.Results.columns ...
    ));

end