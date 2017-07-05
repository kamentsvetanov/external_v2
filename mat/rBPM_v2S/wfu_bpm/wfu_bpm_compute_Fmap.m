function [Fmap] = wfu_bpm_compute_Fmap(BETA_slice,XtX,c,Rc,brain_mask,sig2,Fmap,M,N,nr)
%---------- computing Fmaps for regression ------------------%
for m = 1:M
    for n = 1:N
        if brain_mask(m,n) == 1
            if sig2(m,n) > 0 
                beta = BETA_slice(m,n,:);
                beta = beta(:);
                SSres = sig2(m,n); 
                X_pinv = pinv(reshape(XtX(m,n,:),nr,nr));
                SSc = ((beta'*c)*pinv(c'*X_pinv*c)*(c'*beta))/Rc;
                q = nnz(c);
                Fmap(m,n) = (SSc/q)/(SSres);
                
%                 beta = BETA_slice(m,n,:);
%                 beta = beta(:);
%                 num = ((beta'*c)*pinv(c'*X_pinv*c)*(c'*beta))/Rc;                          
%                 Fmap(m,n) = num/sig2(m,n);
            end
        end
    end
end