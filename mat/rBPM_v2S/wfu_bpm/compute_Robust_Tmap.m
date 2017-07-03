function [RoTmap] = compute_Robust_Tmap(ConImage,XtX,c,brain_mask,sig,RoTmap,M,N,nr)
%---------- computing Fmaps for regression ------------------%
% [R C B] = size(Tvalue);
% for m = 1:M
%     for n = 1:N
%         if brain_mask(m,n) == 1
%                 val = Tvalue(m,n,:);
%                 for i = 2:B
%                     t_val = cat(1,val(1,1,1),val(1,1,i));
%                 end
%                 Romap(m,n) = c'*t_val;   % in regression c>0
%         end
%     end
% end

for m = 1:M
    for n = 1:N
        if brain_mask(m,n) == 1
            if sig(m,n) > 0
                voxelXtX = reshape(XtX(m,n,:),nr,nr);
                cp = c'*pinv(voxelXtX)*c;
                den = sqrt((sig(m,n)).^2.*cp);              
                RoTmap(m,n) = ConImage(m,n)/den ;
            end
        end
    end
end