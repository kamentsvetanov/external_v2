function wfu_bpm_maskInf(Infx, Infy, Infz, mask_fname, maskInf_fname)
% ______________________________________________________________________
%
% This function performs the following task:
%       copies the mask to a new maskInf image, inserting highlights 
%       where Inf values were removed from SPM's estimation of 
%       smoothness
%_______________________________________________________________________
% Input parameters
% Infx            - x mask index position
% Infy            - y mask index position
% Infz            - z mask index position
% mask_fname      - input mask file name
% maskInf_fname   - output mask file name
%_______________________________________________________________________
if length(Infx) < 1
    return;
end
if ~isequal(size(Infx),size(Infy)) || ~isequal(size(Infx),size(Infz))
    error('all indices must be of the same dimension');
end
v = spm_vol(mask_fname);
v2 = v;
v2.fname = maskInf_fname;
v2 = spm_create_vol(v2);
%
vol = spm_read_vols(v);
vol2 = vol;
n = length(Infx);
for i = 1:n
    x = Infx(i);
    y = Infy(i);
    z = Infz(i);
    vol2(x,y,z) = vol2(x,y,z) + 5;
end
%
spm_write_vol(v2, vol2);
