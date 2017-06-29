% Comput F value

function [Romap] = Compute_Nonp_Fmap(Pvalue,dof,brain_mask,Romap,M,N)
%---------- computing Fmaps for regression ------------------%

for m = 1:M
    for n = 1:N
        if brain_mask(m,n) == 1
                Romap(m,n) = spm_invFcdf(1-Pvalue(m,n),dof(1),dof(length(dof)));
        end
    end
end