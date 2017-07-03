function [Tval1,dof, C1, E] = wfu_bpm_cc_roi_tmap_res(D,brain_mask,BPM)
%--------------------------------------------------------------------------
%                         BPM Correlation with ROI
%--------------------------------------------------------------------------


% ------- Computing the index to the voxels contained in mask -------%

[M1,N1] = size(brain_mask);
mask1 = reshape(brain_mask,M1*N1,1)';
indx = find(mask1 == 1);

% The matrices containing the slice information are reshaped. Now the
% information across a voxel will be contained in one column of the new
% matrices.  The voxels outside the region of interest are excluded.

A = D{1};
[M,N,L1] = size(A);
A = reshape(A,M*N,L1)';     
A1 = A(:,indx);

B1 = BPM.ROI_reg*ones(1,size(A1,2));

% Mean and standard deviations are computed voxel wise

Amean = mean(A1);
Bmean = mean(B1);
stdA = std(A1);
stdB = std(B1);

% Computation of the sample correlation coefficients

[M1,N1] = size(A1);

mean_A_mat= ones(M1,1)*Amean;
mean_B_mat= ones(M1,1)*Bmean;
std_A_mat = ones(M1,1)*stdA;
std_B_mat = ones(M1,1)*stdB;

A2        = (A1-mean_A_mat);
B2        = (B1-mean_B_mat);
C         = ((sum(A2.*B2))./(stdA.*stdB))/(M1-1);

% ------- Computing residuals ---------------------%
BETA1     = (stdA./stdB).*C;
BETA0     = Amean - BETA1.*Bmean;
Residuals = A1 - (B1.*(ones(size(B1,1),1)*BETA1) + ones(size(B1,1),1)*BETA0);

% -------- computation of the t-statistics ---------%
dof = M1-2;
Tval = sqrt(dof) * C./sqrt(1-C.^2);

% Reshaping back to the original slice matrix format the matrices
% containing the t-statistics, p-values and correlation coeffcients.

Tval1 = zeros(1,M*N);
Tval1(:,indx) = Tval;
indx_nan = isnan(Tval1);
Tval1(indx_nan) = 0;

C1 = zeros(1,M*N);
C1(:,indx) = C;
indx_nan = isnan(C1);
C1(indx_nan) = 0;
C1 = reshape(C1,M,N);
Tval1 = reshape(Tval1,M,N);

% for  k = 1:size(A1,1)    
%     E{k} = zeros(M,N);
% end
E = zeros(M,N,size(A1,1));
for k = 1:size(A1,1) 
    R = zeros(1,M*N); 
    R(:,indx)   = Residuals(k,:); 
    indx_nan    = isnan(R);
    R(indx_nan) = 0;
    R = reshape(R,M,N);
    E(:,:,k) = R;
end



