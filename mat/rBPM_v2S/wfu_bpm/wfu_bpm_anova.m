function [X,dof,sig2,brain_mask,nsubj,nr,Vtemp] = wfu_bpm_anova(BPM)
% ______________________________________________________________________
%    This function performs the following tasks:
%
%    1) From the master flist reads all the subjects file names. 
%    2) Reads the brain mask.
%    3) Slice by slice loads the data from the corresponding subjects files
%       and performs a one way anova analysis using the glm model
%    4) Stores the betas and residuals in img files.%    
%_______________________________________________________________________
% Input parameters
% flist     - the name of the master flist
% maskfname - the name of the file containing the brain mask
% contrast  - the contrast to be used
% col_conf  - non-imaging covariates
%_______________________________________________________________________
% Output parameters
% X     - desing matrix
% dof   - degrees of freedom 
% sig2  - a matrix with voxels variances
% nsubj - number of subjects 
% nr    - number of regressors
% Vtemp - header information to create analyze files.
%_______________________________________________________________________

% ----- determining the number of entries in the master file --------%

file_names = wfu_bpm_read_flist(BPM.flist);
no_mod = size(file_names,1);
for k = 1:no_mod
    file_names_mod{k} = file_names(k,:);    
end

% ------- get the file names of the subjects ----------------------------%

file_names_subjs = cell(1,no_mod);        
for k = 1:no_mod
    [file_names_subjs{k},no_grp] = wfu_bpm_get_file_names( file_names_mod{k} ); 
end
for k =1:BPM.DMS(1);
    ngsubj(k) = size(file_names_subjs{1}{k},1);
end
nsubj = sum(ngsubj);

[row_fname,col_fname] = size(file_names_mod{1});
no_files = row_fname;     % Number of File names in the flist

% ------ get the file names of the subjects -----------%
[file_names_subjs no_grp] = wfu_bpm_get_file_names( file_names_mod{1});

% ------- determining the size of the images ----------%

file_name = sprintf('%s', file_names_subjs{1}(1,:));
Vtemp     = spm_vol(file_name); 
rows      = Vtemp.dim(1);
cols      = Vtemp.dim(2);
No_slices = Vtemp.dim(3);

% ------- Reading the brain mask -----------------%

Vstruct    = spm_vol(BPM.mask);
cube       = spm_read_vols(Vstruct);
brain_mask = cube > 0;

% Loading the data and computing the one way anova
data = cell(1,no_grp-1);   
sig2 = zeros(rows,cols,No_slices);

if isfield(BPM,'ancova_ROI_reg')
    spm_progress_bar('Init',No_slices,'Computing Ancova with ROI','slices completed');
    nr = no_grp + 2;
else
    nr = no_grp + 1;
    spm_progress_bar('Init',No_slices,'Computing Anova','slices completed');
end
for slice_no = 1:No_slices  
    brain_mask_slice = brain_mask(:,:,slice_no);
    if sum(sum(brain_mask_slice(:))) > 0
        % Load the slice from the above file names
        for ng = 1:no_grp
            data{ng} = wfu_bpm_get_data_slice( file_names_subjs{ng},slice_no);
        end        
        % glm anova
        [beta_coef, X,dof,sig2(:,:,slice_no),Es] = wfu_bpm_glm_anova(data,brain_mask(:,:,slice_no),ngsubj,nr,BPM);  
        wfu_bpm_write_br(BPM.result_dir, 'beta', Vtemp, beta_coef, slice_no);
        wfu_bpm_write_br(BPM.result_dir, 'Res', Vtemp, Es, slice_no);
    else
        beta_coef = zeros(rows,cols,nr);
        Es        = zeros(rows,cols,nsubj);
        wfu_bpm_write_br(BPM.result_dir, 'beta', Vtemp, beta_coef, slice_no);
        wfu_bpm_write_br(BPM.result_dir, 'Res', Vtemp, Es, slice_no);
    end
    
    spm_progress_bar('Set',slice_no);
end

spm_figure('Clear','Interactive');
return



