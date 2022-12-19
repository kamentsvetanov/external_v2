function ldc = VBA_logDet(C,indIn,t)
% computes the log-determinant of matrix C
% function ldc = VBA_logDet(C,indIn,t)
% IN:
%   - C: nxn matrix
%   - indIn: vector of indices that defines a submatrix of C, whose
%   determinant is computed {1:n}
%   - t: threshold on the eigenvlues of the submatrix {eps}
% OUT:
%   - ldc: log-determinant of the submatrix of C

if nargin < 3
    t = eps;
end
if nargin < 2
    indIn=1:size(C,1);
end
ev = eig(full(C(indIn,indIn)));
ev = ev(abs(ev)>=t);
ldc = sum(log(ev));