  function [mask] = generate_inter_mask(P1, BPM);
% __________________________________________________________%
% This function generate a binary brain mask using the individual 
% information from the main modality. The mask is the intersection 
% of all individual masks created by thresholding the individual
% datasets at some %thr of the mean signal.
%___________________________________________________________%
% Input Parameter
%  P1   - Array containing the names of the subjects data sets
%  thr  - a threshold in %
%___________________________________________________________%
% Output Parameter
% mask_file_name   - path and name of the resulting mask
%__________________________________________________________%



% ------- Computing the intersection mask -------------------- %

% ------- Reading one subject header ---------------- %    
Vs = spm_vol(P1(1,:));
inter_mask = zeros(Vs.dim(1),Vs.dim(2),Vs.dim(3));
% if isfield(BPM,'')
% else
% end
spm_progress_bar('Init',size(P1,1),'Generating Mask','number of subjects');
for n = 1:size(P1,1)
    Vs          = spm_vol(P1(n,:))  ;             
    data_subj   = spm_read_vols(Vs);
    data_subjv  = data_subj(:)     ;
    data_subjv(isnan(data_subjv)) = 0;           
    mean_signal = mean(data_subjv);
    data_subj   = reshape(data_subjv, Vs.dim(1:3));
    if isfield(BPM,'mask_pthr')
        mask_subj   = abs(data_subj) > abs(mean_signal)*BPM.mask_pthr ;
    else
        mask_subj   = abs(data_subj) > BPM.mask_athr ;
    end        
    inter_mask = inter_mask + (mask_subj>0);
    spm_progress_bar('Set', n);
end

mask = (inter_mask > size(P1,1)-3);
Vs = wfu_bpm_hdr_struct(Vs);
Vs.fname    = 'mask.img';
spm_write_vol(Vs,mask);
    

    

