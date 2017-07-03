function [RoFmap] = compute_Robust_Fmap(BETA_slice,XtX,c,Rc,brain_mask,sig,RoFmap,M,N,nr)
%---------- computing Fmaps for regression ------------------%
for m = 1:M
    for n = 1:N
        if brain_mask(m,n) == 1
            if sig(m,n) > 0   
                beta = BETA_slice(m,n,:);
                beta = beta(:);
                X_pinv = pinv(reshape(XtX(m,n,:),nr,nr));
                num = ((beta'*c)*pinv(c'*X_pinv*c)*(c'*beta))/Rc;                          
                RoFmap(m,n) = num/sig(m,n);
            end
        end
    end
end

