function [XX,dof,sig2, brain_mask, nsubj, nr, Vtemp] = wfu_bpm_ancova(BPM)
%------------------------------------------------------------------------
%    This function performs the following tasks:
%
%    1) From the master flist reads all the subjects file names. 
%    2) Reads the brain mask.
%    3) Slice by slice load the data from the corresponding subjects files
%       and performs a one way ancova analysis using the glm model where it
%       is possible to use as covariates other imaging modalities data
%    4) The betas and residuals are stored in files.
%-------------------------------------------------------------------------
% Input parameters
% flist     - the name of the master flist
% maskfname - the name of the file containing the brain mask
% col_conf  - non-imaging covariates
%-------------------------------------------------------------------------
% Output parameters
% resulting from the GLM.
% XX   - cell containing 2D cells with the design matrices corresponding to
%       each voxel
% dof  - volume containing the degrees of freedom at ecah voxel
% sig2 - volume containing the variances at each voxel
% nsubj- number of subjects
% nr   - number of regressors
% brain_mask - mask containing the voxels inside the brain region
% Vtemp - information about the analyze images 
%--------------------------------------------------------------------------

flist = BPM.flist; maskfname = BPM.mask; 
col_conf = BPM.conf; XtXfname = BPM.XtX; 
type = BPM.type;
Robust_flag = BPM.robust; % if apply robust regression
Rwfun = BPM.rwfun;
PMaxOut = BPM.pMaxOut;

%   Reading the modality files from the master file 
file_names = wfu_bpm_read_flist(flist);
no_mod = size(file_names,1);
for k = 1:no_mod
    file_names_mod{k} = file_names(k,:);    
end

%  Cell that will contain cells. Each cell element contains 
%  the file names (different groups) corresponding to a different modality 


% get the file names of the subjects 

file_names_subjs = cell(1,no_mod);        
for k = 1:no_mod
    [file_names_subjs{k},no_grp] = wfu_bpm_get_file_names( file_names_mod{k} ); 
end

for k =1:BPM.DMS(1)
    ngsubj(k) = size(file_names_subjs{1}{k},1);
end
nsubj = sum(ngsubj);
% ------- determining the size of the images ---------------------------%

file_name = sprintf('%s', file_names_subjs{1}{1}(1,:));
Vtemp = spm_vol(file_name);
rows      = Vtemp.dim(1);
cols      = Vtemp.dim(2);
No_slices = Vtemp.dim(3);

% Reading the brain mask

Vstruct = spm_vol(maskfname);
cube    = spm_read_vols(Vstruct);
brain_mask    = cube > 0;
    
% load the data and confound from the files
% data is a cell of arrays
data = cell(1,no_grp); 
confound = [] ;


% Reading the non-imaging covariates
if ~isempty(col_conf)
    col_conf = load(col_conf);
else 
    col_conf = [];
end

spm_progress_bar('Init',No_slices,'Computing Betas','slices completed');

%----- Number of regressors --------------%
if strcmp(BPM.type,'REGRESSION')
    nr = sum(BPM.DMS);

else
     nr = sum(BPM.DMS)+1;
end

% Pre-allocating the memory

dof        = zeros(rows,cols,No_slices);
sig2       = zeros(rows,cols,No_slices);
beta_coef  = zeros(rows,cols,nr);
E          = zeros(rows,cols,nsubj);
sig2_slice = zeros(rows,cols);
dof_slice  = zeros(rows,cols);
XX_slice   = zeros(rows,cols,nr*nr);
% sig        = zeros(rows,cols,No_slices);
% sig_slice  = zeros(rows,cols);

% create output file in Big Endian for design matrix

[fid, message] = fopen(XtXfname, 'w', 'b');
if fid == -1
    disp(message);
end
for slice_no = 1:No_slices
    
    if sum(sum(brain_mask(:,:,slice_no))) >0
        for ng = 1:no_grp
            data{ng} = wfu_bpm_get_data_slice( file_names_subjs{1}{ng},slice_no);
            if no_mod > 1
                counter = 1;
                for nm = 2:no_mod
                    confound{counter}{ng} = wfu_bpm_get_data_slice(file_names_subjs{nm}{ng},slice_no); % 
                    counter = counter + 1;
                end        
            end
        end
        %%%%%%%%%%%%%%%%% GLM function %%%%%%%%%%%%%%%%%%%%%%%
        % removing Nans from the data and confounds
        data = wfu_bpm_remove_nan(data);
        
        for ki = 1:max(size(confound))
            confound{ki} = wfu_bpm_remove_nan(confound{ki});
        end
        
               
        [beta_coef,XX,dof(:,:,slice_no),sig2(:,:,slice_no),Es] = wfu_bpm_glm(data,confound,col_conf,brain_mask(:,:,slice_no),type,ngsubj,nr, beta_coef, ... 
            E,sig2_slice,dof_slice,XX_slice,Robust_flag,Rwfun,PMaxOut);
        
        % -------- Storing the beta coefficients -------------- %
        
        wfu_bpm_write_br(BPM.result_dir, 'beta', Vtemp, beta_coef, slice_no);
        wfu_bpm_write_br(BPM.result_dir, 'Res',  Vtemp, Es, slice_no);      
        
        % store all design matrices for slice
        if fid ~= -1
            count = fwrite(fid, XX, 'double');
            if count ~= prod(size(XX))
                str = sprintf('error writing X design matrices at slice %d', slice_no);
                disp(str);
            end
        end
        beta_coef = zeros(rows,cols,nr);  % modify
    else        
        
        beta_coef = zeros(rows,cols,nr);
        Es = zeros(rows,cols,nsubj);
        XX = zeros(rows,cols,nr*nr);
        wfu_bpm_write_br(BPM.result_dir, 'beta', Vtemp, beta_coef, slice_no);
        wfu_bpm_write_br(BPM.result_dir, 'Res',  Vtemp, Es, slice_no);       
        
        % store all design matrices for slice
        if fid ~= -1
            count = fwrite(fid, XX, 'double');
            if count ~= prod(size(XX))
                str = sprintf('error writing X design matrices at slice %d', slice_no);
                disp(str);
            end
        end
    end
    %
    spm_progress_bar('Set',slice_no);    
end


% close design matrix file
if fid ~= -1
    fclose(fid);
end
spm_figure('Clear','Interactive');
return
