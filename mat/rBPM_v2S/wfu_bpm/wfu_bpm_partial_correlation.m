function [T, Cpc, dof, brain_mask, nsubj, Vtemp] = wfu_bpm_partial_correlation(BPM)
%---------------------------------------------------------------------%
%                  BPM Partial Correlation
%---------------------------------------------------------------------%

flist      = BPM.flist; 
maskfname  = BPM.mask ; 
col_conf   = BPM.pc_control_var; 
% XtXfname = BPM.XtX ; 
type       = BPM.type;

%---------- Reading the modality files from the master file------------%
file_names = wfu_bpm_read_flist(flist);
no_mod = size(file_names,1);
for k = 1:no_mod
    file_names_mod{k} = file_names(k,:);    
end

% --------- get the file names of the subjects --------------------------%

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


% ------ Reading the covariates to be remove ----------%

col_conf = load(col_conf);
spm_progress_bar('Init',No_slices,'Computing Partial Correlations','slices completed');

%----- Number of regressors --------------%

nr = size(col_conf,2) + 2;

% Pre-allocating the memory

% dof        = zeros(rows,cols,No_slices);
% sig2       = zeros(rows,cols,No_slices);
Cpc          = zeros(rows,cols,No_slices);
Cpc_slice    = zeros(rows,cols);
T            = zeros(rows,cols,No_slices);
T_slice      = zeros(rows,cols);
E            = zeros(rows,cols,nsubj);
% sig2_slice = zeros(rows,cols);
% dof_slice  = zeros(rows,cols);

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
        
        [Cpc(:,:,slice_no), T(:,:,slice_no), Es] = wfu_bpm_pc_SS(data,confound,col_conf,brain_mask(:,:,slice_no),ngsubj,Cpc_slice,T_slice, E);
        
        % -------- Storing the beta coefficients -------------- %
        wfu_bpm_write_br(BPM.result_dir, 'Res',  Vtemp, Es, slice_no);
        
    else     
       
        Es = zeros(rows,cols,nsubj)    ;
        wfu_bpm_write_br(BPM.result_dir, 'Res',  Vtemp, Es, slice_no);             
            
    end
    %
    spm_progress_bar('Set',slice_no);    
end

dof = sum(ngsubj) - (size(col_conf,2)) - 2 ;
spm_figure('Clear','Interactive');
return
