function [F] = getF(posterior,out,Laplace)

% Conditional Free Energy approximation

if nargin < 3
    Laplace = 0;
end
dim = out.dim;
y = out.y;
suffStat = out.suffStat;
options = out.options;
options.Laplace = Laplace;
[F] = VBA_FreeEnergy(posterior,suffStat,options);