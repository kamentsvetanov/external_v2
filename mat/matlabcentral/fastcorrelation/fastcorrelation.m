function correlation = fastcorrelation(x, y)

%   FASTCORRELATION computes the correlation between vectors x and y by
%   making use of fastcorr.dll which is the C implementation of a fast and
%   numerically stable algorithm.
%
%   In order to generate fastcorr.dll, you need to run this instruction and
%   compile the c file from the Matlab Command Window:
%
%                            mex fastcorr.c
%
%*************************************************************************%
%
%   EXAMPLE1. If you need to check the input vectors:
%   N = 10000000;
%   x = cumsum(randn(N, 1));
%   y = cumsum(randn(N, 1));
%   correlation = fastcorrelation(x, y);
%
%*************************************************************************%
%
%   EXAMPLE2. If you DON'T need to check the input vectors:
%   N = 10000000;
%   x = cumsum(randn(N, 1));
%   y = cumsum(randn(N, 1));
%   correlation = fastcorr(x, y);
%
%*************************************************************************%
%
%   EXAMPLE3. Check running time and accuracy of corrcoef and fastcorr
%
%   format long
%   for N = 50:50:100000
%     x = cumsum(randn(N, 1));
%     y = cumsum(randn(N, 1));
%     tic, temp = corrcoef(x, y); correlation1(N / 50) = temp(2); runningtime1(N / 50) = toc; [N, toc]
%     tic, correlation2(N / 50) = fastcorr(x, y); runningtime2(N / 50) = toc; [N, toc]
%     disp(sprintf('\n\n\n'))
%   end
%   % Check running times (blue for corrcoef, magenta for fastcorr):
%   figure
%   plot(runningtime1, '.b');
%   hold on;
%   plot(runningtime2, '.m');
%
%   % Check running times (positive means corrcoef > fastcorr, negative means fastcorr > corrcoef):
%   figure
%   plot(runningtime1 - runningtime2, '.b');
%
%   % Compare accuracy of computation (differences are negligible):
%   figure
%   plot(correlation1 - correlation2, '.')
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

correlation = fastcorr(x, y);
