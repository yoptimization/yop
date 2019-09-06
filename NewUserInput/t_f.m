function t = t_f(varargin)

if nargin == 0
    t = YopVar.getIndependentFinal;
    
elseif nargin == 1
    t = YopVarTimed(varargin{1}, YopVar.getIndependentFinal.Value);
end

end