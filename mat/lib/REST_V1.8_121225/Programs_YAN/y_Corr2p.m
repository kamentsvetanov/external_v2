function p = y_Corr2p(r,n)
% Pearson's correlation coefficient to significance (p)
% input: r - correlation vector, 1 by n
%        n - number of pairs
% Written by YAN Chao-Gan 090108, referenced from matlab's corrcoef

   m = length(r);
   rv = r;
   lhsize = size(rv);
   nv = n;

   % Tstat=Inf and p=0 if abs(r)==1
   denom = (1 - rv.^2);
   Tstat = Inf + zeros(size(rv));
   Tstat(rv<0) = -Inf;

   t = denom>0;
   rv = rv(t);
   if length(n)>1
      nvt = nv(t);
   else
      nvt = nv;
   end
   Tstat(t) = rv .* sqrt((nvt-2) ./ denom(t));
   p = 0*r;

   p = 2*tpvalue(-abs(Tstat),nv-2);
   risnan = isnan(r);
   p(risnan) = NaN;
   
%    p(lowerhalf) = 2*tpvalue(-abs(Tstat),nv-2);
%    p = p + p' + eye(m,'double');
%    risnan = isnan(r);
%    p(risnan) = NaN;
  
function p = tpvalue(x,v)
%TPVALUE Compute p-value for t statistic

normcutoff = 1e7;
if length(x)~=1 && length(v)==1
   v = repmat(v,size(x));
end

% Initialize P to zero.
p=zeros(size(x));

% use special cases for some specific values of v
k = find(v==1);
if any(k)
    p(k) = .5 + atan(x(k))/pi;
end
k = find(v>=normcutoff);
if any(k)
    p(k) = 0.5 * erfc(-x(k) ./ sqrt(2));
end

% See Abramowitz and Stegun, formulas 26.5.27 and 26.7.1
k = find(x ~= 0 & v ~= 1 & v > 0 & v < normcutoff);
if any(k),                            % first compute F(-|x|)
    xx = v(k) ./ (v(k) + x(k).^2);
    p(k) = betainc(xx, v(k)/2, 0.5)/2;
end

% Adjust for x>0.  Right now p<0.5, so this is numerically safe.
k = find(x > 0 & v ~= 1 & v > 0 & v < normcutoff);
if any(k), p(k) = 1 - p(k); end

p(x == 0 & v ~= 1 & v > 0) = 0.5;

% Return NaN for invalid inputs.
p(v <= 0 | isnan(x) | isnan(v)) = NaN;