function y_RobustFit_Image(DependentDir,Predictor,OutputName,MaskFile,IsNeedOLSRegress)
% function y_RobustFit_Image(DependentDir,Predictor,OutputName,MaskFile,IsNeedOLSRegress)
% Perform robust regression analysis
% Input:
%   DependentDir - the image directory of the group
%   Predictor - the Predictors M (subjects) by N (traits)
%   OutputName - the output name.
%   MaskFile - the mask file.
%   IsNeedOLSRegress - 1 means also want the ordinary least square regression results.
% Output:
%   b, t, p - beta, t value, and p value files results
%___________________________________________________________________________
% Written by YAN Chao-Gan 111005.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

if nargin<=4
    IsNeedOLSRegress=0;
    if nargin<=3
        MaskFile=[];
    end
end


[DependentVolume,VoxelSize,theImgFileList, Header] =rest_to4d(DependentDir);
fprintf('\n\tImage Files in the Group:\n');
for itheImgFileList=1:length(theImgFileList)
    fprintf('\t%s%s\n',theImgFileList{itheImgFileList});
end


[nDim1,nDim2,nDim3,nDim4]=size(DependentVolume);

if ~isempty(MaskFile)
    [MaskData,MaskVox,MaskHead]=rest_readfile(MaskFile);
else
    MaskData=ones(nDim1,nDim2,nDim3);
end

rest_waitbar;

b_robust_brain=zeros(nDim1,nDim2,nDim3,size(Predictor,2)+1);
t_robust_brain=zeros(nDim1,nDim2,nDim3,size(Predictor,2)+1);
p_robust_brain=zeros(nDim1,nDim2,nDim3,size(Predictor,2)+1);

b_OLS_brain=zeros(nDim1,nDim2,nDim3,size(Predictor,2)+1);
t_OLS_brain=zeros(nDim1,nDim2,nDim3,size(Predictor,2)+1);
p_OLS_brain=zeros(nDim1,nDim2,nDim3,size(Predictor,2)+1);


fprintf('\n\tRegression Calculating...\n');
for i=1:nDim1
    rest_waitbar(i/nDim1, 'Regression Calculating...', 'Regression Analysis','Child');
    fprintf('.');
    for j=1:nDim2
        for k=1:nDim3
            if MaskData(i,j,k)
                DependentVariable=squeeze(DependentVolume(i,j,k,:));
                if any(DependentVariable)
                    
                    [b_robust,stats_robust] = robustfit(Predictor,DependentVariable);
                    
                    b_robust_brain(i,j,k,:)=b_robust;
                    t_robust_brain(i,j,k,:)=stats_robust.t;
                    p_robust_brain(i,j,k,:)=stats_robust.p;

                    if IsNeedOLSRegress
                        
                        stats_regstats=regstats(DependentVariable,Predictor);
                        
                        b_OLS_brain(i,j,k,:)=stats_regstats.tstat.beta;
                        t_OLS_brain(i,j,k,:)=stats_regstats.tstat.t;
                        p_OLS_brain(i,j,k,:)=stats_regstats.tstat.pval;
                        
                    end
                end
            end
        end
    end
end
b_robust_brain(isnan(b_robust_brain))=0;
t_robust_brain(isnan(t_robust_brain))=0;
p_robust_brain(isnan(p_robust_brain))=1;
b_OLS_brain(isnan(b_OLS_brain))=0;
t_OLS_brain(isnan(t_OLS_brain))=0;
p_OLS_brain(isnan(p_OLS_brain))=1;

DOF = nDim4 - size(Predictor,2) - 1;
HeaderTWithDOF=Header;
HeaderTWithDOF.descrip=sprintf('REST{T_[%.1f]}',DOF);

for ii=1:size(b_robust_brain,4)
    rest_WriteNiftiImage(squeeze(b_robust_brain(:,:,:,ii)),Header,[OutputName,'_b_robust_',num2str(ii-1),'.img']);
    rest_WriteNiftiImage(squeeze(t_robust_brain(:,:,:,ii)),HeaderTWithDOF,[OutputName,'_t_robust_',num2str(ii-1),'.img']);
    rest_WriteNiftiImage(squeeze(p_robust_brain(:,:,:,ii)),Header,[OutputName,'_p_robust_',num2str(ii-1),'.img']);
    
    if IsNeedOLSRegress
        rest_WriteNiftiImage(squeeze(b_OLS_brain(:,:,:,ii)),Header,[OutputName,'_b_OLS_',num2str(ii-1),'.img']);
        rest_WriteNiftiImage(squeeze(t_OLS_brain(:,:,:,ii)),HeaderTWithDOF,[OutputName,'_t_OLS_',num2str(ii-1),'.img']);
        rest_WriteNiftiImage(squeeze(p_OLS_brain(:,:,:,ii)),Header,[OutputName,'_p_OLS_',num2str(ii-1),'.img']);
    end
    
end

rest_waitbar;
fprintf('\n\tRegression Calculation finished.\n');
