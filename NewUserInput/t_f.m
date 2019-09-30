function t = t_f(varargin)

if nargin == 0
    t = YopVar.getIndependentFinal;
    
elseif nargin == 1
    t = YopVar(varargin{1}, YopVar.getIndependentFinal);
end

end