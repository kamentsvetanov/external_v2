function Tmap = bnpm_compute_Tmap(ConImage,XtX,c,brain_mask,sig2,Tmap,M,N,nr)
% Computing the Tmaps for ancova bnpm and regression bnpm
for m = 1:M
    for n = 1:N
        if brain_mask(m,n) == 1
            if sig2(m,n) > 0
                voxelXtX = reshape(XtX(m,n,:),nr,nr);
                cp = c'*pinv(voxelXtX)*c;
                den = sqrt(sig2(m,n).*cp);                
%                 den = sqrt(max(sig2(m,n).*cp,eps(class(sig2(m,n))))); % don't let t value be too large              
                Tmap(m,n) = ConImage(m,n)/den;
            end
        end
    end
end


