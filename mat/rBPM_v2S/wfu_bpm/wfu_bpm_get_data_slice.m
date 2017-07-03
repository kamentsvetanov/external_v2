function data = wfu_bpm_get_data_slice( file_names_subjs,slice_no)
% _______________________________________________________________________
% This function reads a given slice from a group of files containing data
% corresponding to a group of subjects.
%________________________________________________________________________
% Input Parameters
%   file_names subjects - Array containg the paths and names of a group
%                         of files.
%   slice_no            - Slice number.
%________________________________________________________________________
% Output Parameter
%   data  - 3D array containing the slices number slice_no of the group of
%           files.
%_________________________________________________________________________

No_subj = size(file_names_subjs,1);
V = spm_vol(deblank(file_names_subjs(1,:)));
data = zeros(V.dim(1),V.dim(2),No_subj);
for k = 1:No_subj
     V = spm_vol(deblank(file_names_subjs(k,:)));
     slice = spm_slice_vol(V,spm_matrix([0 0 slice_no]),V.dim(1:2),0);
     data(:,:,k) = slice;
end

