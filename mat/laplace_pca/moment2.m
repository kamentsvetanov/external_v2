function s = moment2(x,m)

if nargin == 2
  x = x - repmat(m, 1, cols(x));
end
s = x*x'/cols(x);
