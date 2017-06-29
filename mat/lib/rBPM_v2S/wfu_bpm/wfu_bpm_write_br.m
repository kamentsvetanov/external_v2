function wfu_bpm_write_br(dir, prefix, V, E, slice_no)
% ______________________________________________________________________
%
% This function performs the following task:
%       Outputs intermediate residuals or betas
%       for the specified slice for each subject
%_______________________________________________________________________
% Input parameters
% dir       - path of output directory
% prefix    - file name prefix
% V         - header structure for output residual/beta files
% E         - volume of residuals/beta for all subjects at this slice
% slice_no  - slice number, or position in output volume
%_______________________________________________________________________

nsubj = size(E, 3);
if (nsubj > 999)
    error(sprintf('%d subjects > 999 max number of subjects'), nsubj);
end
if slice_no == 1
    Vs = wfu_bpm_hdr_struct(V);
    for k = 1:nsubj
        Vs.fname = fullfile(dir, sprintf('%s%03d.img', prefix, k));
        V0 = spm_create_vol(Vs);
        V0 = spm_write_plane(V0, E(:,:,k), slice_no);
        if exist('spm_close_vol')
            spm_close_vol(V0);
        end
    end
else
	for k = 1:nsubj
        fname = fullfile(dir, sprintf('%s%03d.img', prefix, k));
        VO = spm_vol(fname);
        VO = spm_write_plane(VO, E(:,:,k), slice_no);
        if exist('spm_close_vol')
            spm_close_vol(VO);
        end
	end
end
