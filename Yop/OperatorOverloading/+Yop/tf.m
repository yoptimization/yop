function t = tf(varargin)

if nargin == 0
    t = Yop.getIndependentFinal;
    
elseif nargin == 1
    t = Yop.Expression(varargin{1}, Yop.getIndependentFinal);
end

end