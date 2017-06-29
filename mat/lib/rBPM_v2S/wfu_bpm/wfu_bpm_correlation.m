function [Tmap, dof, C, brain_mask, Ts,Vtemp] = wfu_bpm_correlation(BPM)
%----------------------------------------------------------------------------%
%                        BPM Correlation                                     %                         
%  This function is for carrying out correlation between two data sets       %
%  coming for different imaging modalities.  The correlation is computed     %
%  voxelwise  voxel and one slice at a time.                                 %
%  --------------------------------------------------------------------------%
% Input parameters                                                           %
%       BPM structure                                                        %
% ---------------------------------------------------------------------------%
% Output parameters                                                          %
% Tmap        - generated Tmap                                               % 
% dof         - degrees of freedom                                           %
% C           - Correlation field                                            %
% brain_mask  - brain mask                                                   %
% Ts          - Total number of subjects                                     %
% Vtemp       - header of the analyze file                                   %
%----------------------------------------------------------------------------%

flist = BPM.flist; maskfname = BPM.mask; 
% --------- Reading the master file ------------------------------------%

file_names = wfu_bpm_read_flist(flist);
no_mod = size(file_names,1);
for k = 1:no_mod
    file_names_mod{k} = file_names(k,:);    
end

% Cell that will contain cells. Each cell element contains the file
% names (different groups) corresponding to a different modality.

file_names_subjs = cell(1,no_mod);    

% ------- get the file names of the subjects ---------------------------%
for k = 1:no_mod
    [file_names_subjs{k},no_grp] = wfu_bpm_get_file_names( file_names_mod{k} ); 
end

Ts  = size(file_names_subjs{1}{1},1);

% -------- determining the size of the images ----------%
file_name = sprintf('%s', file_names_subjs{1}{1}(1,:));
Vtemp = spm_vol(file_name); 
rows      = Vtemp.dim(1);
cols      = Vtemp.dim(2);
No_slices = Vtemp.dim(3);

% -------- Reading the brain mask -------------------%
if ~isempty(maskfname)
    Vstruct = spm_vol(maskfname);
    cube    = spm_read_vols(Vstruct);
    brain_mask    = cube > 0;
end

% if isfield(BPM,'pc_control_var')
%     X = load(BPM.pc_control_var);
% else
%     X = [];
% end

data = cell(1,2);  
Tmap = zeros(rows,cols,No_slices);
C    = zeros(rows,cols,No_slices);
E    = zeros(rows,cols,Ts);
spm_progress_bar('Init',No_slices,'Computing Correlation','slices completed');
for slice_no = 1:No_slices  
    brain_mask_slice = brain_mask(:,:,slice_no);
    if sum(sum(brain_mask_slice(:)))>0
        % -------- Reading the data ------------------%
        data{1} = wfu_bpm_get_data_slice( file_names_subjs{1}{1},slice_no);
        data{2} = wfu_bpm_get_data_slice( file_names_subjs{2}{1},slice_no);
        % -------- removing Nans from the data and confounds----------%
        data = wfu_bpm_remove_nan(data);
        % -------- computing the correlation coeffients and Tmap------%
        [Tmap(:,:,slice_no), dof, C(:,:,slice_no), E]   = wfu_bpm_cc_tmap_res(data, brain_mask_slice);
        % -------- storing the residuals to files  -----%
        wfu_bpm_write_br(BPM.result_dir, 'Res', Vtemp, E, slice_no);
    else        
        E = zeros(rows,cols,Ts);
        wfu_bpm_write_br(BPM.result_dir, 'Res', Vtemp, E, slice_no);
    end    
    spm_progress_bar('Set',slice_no);
end
spm_figure('Clear','Interactive');
return


