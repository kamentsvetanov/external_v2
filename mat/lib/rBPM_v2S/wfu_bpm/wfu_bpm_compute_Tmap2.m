function Tmap = wfu_bpm_compute_Tmap2(ConImage,X,c,brain_mask,sig2,Tmap,M,N)
% Computing the Tmaps for anova and ancova with ROI
cp = c'*pinv(X'*X)*c;
for m = 1:M
    for n = 1:N
        if brain_mask(m,n) == 1
            if sig2(m,n) > 0
                den = sqrt(sig2(m,n).*cp);              
                Tmap(m,n) = ConImage(m,n)/den ;
            end
        end
    end
end
