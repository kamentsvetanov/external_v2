%_______________________________________________
function [M,origin] = wfu_image2mni(image)
%-----------------------------------------------------------------------
%Computes affine transformation matrix for image space to MNI mm space (full tal)
%If it's normalized, it just returns MG
%otherwise, it hunts for sn3d intermediary and computes appropriate mat
%------------------------------------------------------------------------
%Affine = native_display -> MNI display
%MG	= MNI_display	 -> full tal
%MF	= native_display -> magnet
%sag->ax = M_ax\M_sag
%MNI_origin = inv(MG) * acpc' = MG\acpc'
%full_tal->native_display = Affine/MG
%native_display->full_tal = MG/Affine = inv(Affine/MG)
%native_display->full_tal = MNI_display->full_tal) / (native_display->MNI_display)
%object2fulltal = (MG/Affine) * (MF\M0)
%sag2fulltal	= (native_ax_display ->full_tal) * (sag2ax)
%JAM 10-25-05
%-----------------------------------------------------------------------

V = spm_vol(image);
[normalized,mat,M,spm99_norm] = wfu_isnormalized(image,V);
%M = spm_get_space(image);
M = V.mat;
%if M(:,4) == [92 -128 -74 1]'; tal = 1; end

if ~normalized
	M0 = M;
	version=spm('Ver');
	switch version
		case 'SPM99'
			spm99_flag = 1;
		otherwise
			spm99_flag = 0;
	end
	[pth,fname,ext] = fileparts(image);
	if isempty(pth), pth = pwd; end;
	filter99 = '*sn3d.mat';
	filter5  = '*_sn.mat';
	sn3dfile = spm_get('files',pth,filter99);
	spm99_flag = 1;
	if isempty(sn3dfile) sn3dfile = spm_get('files',pth,filter5); spm99_flag = 0; end;
	if ~isempty(sn3dfile) sn3dfile = sn3dfile(1,:); end;
	if exist(sn3dfile) == 2,
		disp(sn3dfile);
		params = load(sn3dfile);
		%---------------------------------------------------
		%Here is the logic for the sn3d transformations
		%---------------------------------------------------
		%magnet_ax2MNIv = Affine;
		%ax2magnet = MF;
		%epi2magnet = Mepi;
		%epi2ax= MF\Mepi;
		%ax2axMNIv = Affine;
		%ax2MNIw = MG/Affine;
		%epi2MNIw = (MG/Affine) * (MF\Mepi)
		if ~spm99_flag
			MG = params.VG.mat;
			Affine = params.Affine;
			MF = params.VF.mat;
			origin0 = V.private.hdr.hist.origin;
		else
			MG = params.MG;
			Affine = params.Affine;
			MF = params.MF;
			if isfield(V,'wfu'), M0 = V.wfu.M; end;
		end	
		%Affine = native_display -> MNI display
		%MG	= MNI_display	 -> full tal
		%MF	= native_display -> magnet
		%sag->ax = M_ax\M_sag
		%MNI_origin = inv(MG) * acpc' = MG\acpc'
		%full_tal->native_display = Affine/MG
		%native_display->full_tal = MG/Affine = inv(Affine/MG)
		%native_display->full_tal = MNI_display->full_tal) / (native_display->MNI_display)
		%object2fulltal = (MG/Affine) * (MF\M0)
		%sag2fulltal	= (native_ax_display ->full_tal) * (sag2ax)
		
		M = (MG/Affine) * (MF\M0);  
		acpc = [0 0 0 1];
		origin_native = Affine/MG/acpc;
		origin_bymat = M\acpc';
		origin = origin_native;
	else,
		fprintf('\n  Unable to Compute MNI transform');
		fprintf('\n  Transformation Matrix may be in error.');
	end;

end
return
