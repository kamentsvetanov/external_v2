function [normalized,mat,M,spm99_norm] = wfu_isnormalized(fname,V)
%------------------------------------
%returns 1 if the file is normalized
%mat is SPM2/5 mat file
%M is for SPM99
%------------------------------------
spm99_norm = 0;
if ~exist('V'), V = spm_vol(fname); end;
if isfield(V,'wfu')
	M = V.wfu.M;
	mat = V.wfu.mat;
	normalized = V.wfu.normalized;
	return;
end
mat = V.mat;
dims = V.dim;
if size(dims) < 4, dims = [dims 1]; end;
bb = diag(V.mat)' .* dims;
bb = abs(bb(1:3));
tol = 5;
td = [182 218 182]; 
not_normalized = sum(floor(abs(bb - td)/tol));
normalized = 0;
if not_normalized == 0, normalized = 1; end;
%-------------------------
%check description field
%-------------------------
norm_flag = regexpi(V.descrip,'spm - 3D normalized');
if norm_flag, normalized = 1; end;
M = mat(:,:,1); if spm_flip_analyze_images, M = diag([-1 1 1 1])*M; end;
%------------
%spm99 check
%------------
spm99_norm = wfu_spm99check(fname,V);
if spm99_norm, mat = M; end;
if normalized, M = mat; end;
%disp('wfu_isnormalized');
%fname
%normalized
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function spm99_flag = wfu_spm99check(fname,V)
if ~exist('V'), V = spm_vol(fname); end
quiet=1;
spm99_flag = 0;
private = fieldnames(V.private);
%---------------------------------------------------
%SPM5 structure returns this field for spm99 files
%---------------------------------------------------
if any(strcmp('aux_file',private))
	aux_file = deblank(V.private.aux_file);
	if strcmp(aux_file,'none'), 
		spm99_flag = 1;
	end
	return
end

aux_file = deblank(V.private.hdr.hist.aux_file);
if strcmp(aux_file,'none'), spm99_flag = spm99_flag + 1; end
generated = deblank(V.private.hdr.hist.generated);
if strcmp(generated,''), spm99_flag = spm99_flag + 1; end
if strcmp(fname(1),'n'), spm99_flag = spm99_flag + 1; end
if spm99_flag > 1
	if ~quiet, disp([fname ' appears to be SPM99 normalized']); end;
else
    spm99_flag = 0;
end	
return

