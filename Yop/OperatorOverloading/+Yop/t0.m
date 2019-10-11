function t = t0(varargin)

if nargin == 0
    t = Yop.getIndependentInitial;
    
elseif nargin == 1
    t = t0(Yop.Variable(varargin{1}));
end

end