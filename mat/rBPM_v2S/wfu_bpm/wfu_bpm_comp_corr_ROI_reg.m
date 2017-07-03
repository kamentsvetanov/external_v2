function [ROI_reg] = wfu_bpm_comp_corr_ROI_reg(BPM)

% --------- Reading the data from the second modality --------------------%

file_names                   = wfu_bpm_read_flist(BPM.flist);
file_names_mod{1}            = file_names(2,:);     
file_names_subjs             = cell(1,1);    
[file_names_subjs{1},no_grp] = wfu_bpm_get_file_names( file_names_mod{1} ); 
Ts                           = size(file_names_subjs{1}{1},1);

% -------- determining the size of the images ----------%

file_name  = sprintf('%s', file_names_subjs{1}{1}(1,:));
Vtemp      = spm_vol(file_name); 
rows       = Vtemp.dim(1);
cols       = Vtemp.dim(2);
No_slices  = Vtemp.dim(3);

% -------- Reading the ROI mask -------------------%

Vstruct    = spm_vol(BPM.mask_ROI);
cube       = spm_read_vols(Vstruct);
mask_ROI   = cube > 0  ;

% ------- Computing the ROI regressor -------------%

data       = cell(1,1) ;  
spm_progress_bar('Init', No_slices,'Computing the ROI regressor','slices completed');
ROI_reg = zeros(Ts,1) ;
N_voxels_ROI_mask = sum(mask_ROI(:));
for slice_no = 1:No_slices 
    mask_slice = mask_ROI(:,:,slice_no);
    if sum(mask_slice(:)) > 0
        slice_data    =  wfu_bpm_get_data_slice( file_names_subjs{1}{1},slice_no);         
%         [M1,N1] = size(mask_slice);
        mask1 = reshape(mask_slice,rows*cols,1)';
        indx = find(mask1 == 1);    
%         [M,N,L1] = size(slice_data);
        A = reshape(slice_data,rows*cols,Ts)';     
        A1 = A(:,indx);
        ROI_reg = ROI_reg + sum(A1,2);
    end
    spm_progress_bar('Set',slice_no);
end
ROI_reg = ROI_reg/N_voxels_ROI_mask;
spm_figure('Clear','Interactive');
return
