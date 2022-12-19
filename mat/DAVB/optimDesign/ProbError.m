function [pe] = ProbError(mus,Qs,ps,in)
% Numerical evalaution of 1D binary classification error

n = length(mus);         % number of models to be compared

try
    gri = in.gri;
catch
    gri = -10:1e-3:10;
end
gri = gri(:);

p = zeros(length(gri),n);
for i= 1:n
   
    tmp = mus{i}-gri;
    p(:,i) = exp(-0.5*tmp.^2./Qs{i});
    p(:,i) = ps(i).*p(:,i)./sum(p(:,i));
    
end
sump = sum(p,2);
maxp = max(p,[],2);
pe = sum(sump-maxp);
