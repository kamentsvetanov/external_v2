function y_reorient(PP,vx)
% Re-orient images
% The function reslices the input images to a resolution of 1mm.
% Output images (with the prefix "r") are written in the transverse
% orientation (using information from the ".mat" files).
% 
% From email "Re: reslicing in SPM5" posted  Mon, 5 Jun 2006 13:02:05 +0100
%_______________________________________________________________________
% Revised by YAN Chao-Gan based on GONG Gao-Lang's revision. Originally written by John Ashburner %E%

% If no arguments, then prompt for images
if nargin<1, PP = spm_select(Inf,'image','Select files to reorient'); end;

% vx = 3;

% Get information about the image volumes
VV = spm_vol(PP);

for V=VV', % Loop over images

	% The corners of the current volume
	d = V.dim(1:3);
	c = [	1    1    1    1
		1    1    d(3) 1
		1    d(2) 1    1
		1    d(2) d(3) 1
		d(1) 1    1    1
		d(1) 1    d(3) 1
		d(1) d(2) 1    1
		d(1) d(2) d(3) 1]';

	% The corners of the volume in mm space
	tc = V.mat(1:3,1:4)*c;
	if spm_flip_analyze_images, tc(1,:) = -tc(1,:); end;

	% Max and min co-ordinates for determining a bounding-box
	mx = round(max(tc,[],2)');
	mn = round(min(tc,[],2)');

	% Translate so that minimum moves to [1,1,1]
	% This is the key bit for changing voxel sizes,
	% output orientations etc.
	mat = spm_matrix(mn)*diag([vx vx vx 1])*spm_matrix(-[1 1 1]);

	% Dimensions in mm
	dim = ceil((mat\[mx 1]')');

	% Output image based on information from the original
	VO               = V;
        VO.private       = [];

	% Create a filename for the output image (prefixed by 'r')
	[lpath,name,ext] = fileparts(V.fname);
	VO.fname         = fullfile(lpath,['reoriented_' name ext]);

	% Dimensions of output image
	VO.dim(1:3)      = dim(1:3);

	% Voxel-to-world transform of output image
	if spm_flip_analyze_images, mat = diag([-1 1 1 1])*mat; end;
	VO.mat           = mat;

	% Initialise plot of how far reslicing has gone
	spm_progress_bar('Init',dim(3),'reslicing...','planes completed');

	% Create .hdr and open output .img
	VO = spm_create_vol(VO);

	for i=1:dim(3), % Loop over slices of output image

		% Mapping from slice i of the output image,
		% to voxels of the input image
		M   = inv(spm_matrix([0 0 -i])*inv(VO.mat)*V.mat);

		% Extract this slice according to the mapping
		img = spm_slice_vol(V,M,dim(1:2),1);

		% Write this slice to output image
		spm_write_plane(VO,img,i);

		% Update the progress bar
		spm_progress_bar('Set',i);

	end; % End loop over output slices

	% Get rid of the progress bar
	spm_progress_bar('Clear');

end; % End loop over images

return; % Done