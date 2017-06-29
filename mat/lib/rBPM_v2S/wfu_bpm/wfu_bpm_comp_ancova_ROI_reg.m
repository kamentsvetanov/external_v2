function [ROI_reg] = wfu_bpm_comp_ancova_ROI_reg(BPM)
%-------------------------------------------------------------------
%             Computes ROI regressor for ANCOVA
%-------------------------------------------------------------------

flist = BPM.flist; maskfname = BPM.mask_ancova_ROI; 
col_conf = BPM.conf; 
type = BPM.type;

%   Reading the modality files from the master file 

file_names = wfu_bpm_read_flist(flist);
no_mod = size(file_names,1);
for k = 1:no_mod
    file_names_mod{k} = file_names(k,:);    
end

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

% -------- Reading the ROI mask -------------------%

Vstruct    = spm_vol(BPM.mask_ancova_ROI);
cube       = spm_read_vols(Vstruct);
mask_ancova_ROI   = cube > 0  ;
    
spm_progress_bar('Init',No_slices,'Computing ANCOVA ROI regressor','slices completed');
ancova_ROI_reg = zeros(nsubj,1);
N_voxels_ROI_mask = sum(mask_ancova_ROI(:));
ROI_reg = zeros(nsubj,1);
for slice_no = 1:No_slices   
    mask_slice = mask_ancova_ROI(:,:,slice_no);
    if sum(mask_slice(:)) >0
        mask1 = reshape(mask_slice,rows*cols,1)';
        indx = find(mask1 == 1);    
        B = zeros(nsubj,length(indx));
        for ng = 1:no_grp                      
            slice_data = zeros(rows,cols,ngsubj(ng));
            slice_data = wfu_bpm_get_data_slice(file_names_subjs{2}{ng},slice_no);          
            A = reshape(slice_data,rows*cols,ngsubj(ng))';     
            A1 = A(:,indx);
            B(1+ngsubj(ng)*(ng-1):ngsubj(ng)*ng,:) = A1;        
        end
        ROI_reg = ROI_reg + sum(B,2);         
    end    
    spm_progress_bar('Set',slice_no);    
end
ROI_reg = ROI_reg/N_voxels_ROI_mask;
spm_figure('Clear','Interactive');
return
