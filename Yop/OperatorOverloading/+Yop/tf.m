function t = tf(varargin)

if nargin == 0
    t = Yop.getIndependentFinal;
    
elseif nargin == 1
    t = tf(Yop.Variable(varargin{1}));
    
end

end