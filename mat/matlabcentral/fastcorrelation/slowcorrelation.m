function correlation = slowcorrelation(x, y)

%   CORRELATION is the implementation of an algorithm which computes the
%   correlation between vectors x and y in a numerically stable manner
%
%   This function makes use of loops: thus, the MATLAB version is very slow
%   and is NOT supposed to be used for real computations but only for
%   general consultation.
%
%   EXAMPLE
%   N = 1000;
%   x = cumsum(randn(N, 1));
%   y = cumsum(randn(N, 1));
%   correlation = slowcorrelation(x, y);
%
%*************************************************************************%
%
%-*-* -*-* -*-* -*-* -*-* -*-* -*-* -*-* -*-* -*-* -*-* -*-* -*-* -*-* -*-* -*-*%
%                                                                                               %
%            Author: Liber Eleutherios                                             %
%            E-Mail: libereleutherios@gmail.com                             %
%            Date: 4 December 2008                                              %
%                                                                                               %
%-*-* -*-* -*-* -*-* -*-* -*-* -*-* -*-* -*-* -*-* -*-* -*-* -*-* -*-* -*-* -*-*%
%
%*************************************************************************%


% Check input
ctrl = isvector(x) & isreal(x) & ~any(isnan(x)) & ~any(isinf(x));
ctrl = ctrl & isvector(y) & isreal(y) & ~any(isnan(y)) & ~any(isinf(y));
if ~ctrl
  error('Check x and y: they need be vectors of real numbers with no infinite or nan values!')
end
N = length(x);
ctrl = (N == length(y)) & (N > 1);
if ~ctrl
  error('Vectors need be of same length (at least two elements)')
end

sum_sq_x = 0;
sum_sq_y = 0;
sum_coproduct = 0;
mean_x = x(1);
mean_y = y(1);
for i = 2:N
  sweep = (i - 1.0) / i;
  delta_x = x(i) - mean_x;
  delta_y = y(i) - mean_y;
  sum_sq_x = sum_sq_x + delta_x * delta_x * sweep;
  sum_sq_y = sum_sq_y + delta_y * delta_y * sweep;
  sum_coproduct = sum_coproduct + delta_x * delta_y * sweep;
  mean_x = mean_x + delta_x / i;
  mean_y = mean_y + delta_y / i ;
end
pop_sd_x = sqrt(sum_sq_x / N);
pop_sd_y = sqrt(sum_sq_y / N);
cov_x_y = sum_coproduct / N;
correlation = cov_x_y / (pop_sd_x * pop_sd_y);
