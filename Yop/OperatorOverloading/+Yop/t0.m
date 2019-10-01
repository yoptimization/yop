function t = t0(varargin)

if nargin == 0
    t = Yop.getIndependentInitial;
    
elseif nargin == 1
    t = Yop.Expression(varargin{1}, Yop.getIndependentInitial);
end

end