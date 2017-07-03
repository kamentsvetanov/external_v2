% Comput T value

function [Romap] = Compute_Nonp_Tmap(Pvalue,dof,brain_mask,Romap,M,N)
%---------- computing Tmaps for regression ------------------%
for m = 1:M
    for n = 1:N
        if brain_mask(m,n) == 1
            if Pvalue(m,n) == 1
                Pvalue(m,n) = 1-1e-6; % should be 1-0.1*(1/nPiCond) to control precision
            end
                Romap(m,n) = spm_invTcdf(1-Pvalue(m,n),dof);
        end
    end
end
