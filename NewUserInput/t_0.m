function t = t_0(varargin)

if nargin == 0
    t = YopVar.getIndependentInitial;
    
elseif nargin == 1
    t = YopVarTimed(varargin{1}, YopVar.getIndependentInitial.Value);
end

end