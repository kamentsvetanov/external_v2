function V = wfu_spm_vol_ana(fname, n)

if ~exist('n'), V = spm_vol_ana(fname);
	else,          V = spm_vol_ana(fname,n); 
end;
[pth,nam,ext] = fileparts(deblank(fname));
hfname = fullfile(pth,[nam '.hdr']);
mfname = fullfile(pth,[nam '.mat']);
fname  = fullfile(pth,[nam   ext]);
%-------------------------------------------------------------
%If a .mat exists, check if it was created from an spm99 file (BPM Tmaps)
%The purpose of this is just to set a flag that the mat and M
%are the same, so that a negative voxel dim is not created in the
%call to spm_create_vol
%We will use the wfu_spm99norm flag for this
%If mat = M, then either it is an spm99 type normalized file
%or, spm_flip_analyze is 0, and it doesn't matter
%-------------------------------------------------------------
if exist(mfname)
	mcheck = load(mfname);
	if isfield(mcheck,'wfu'), V.wfu = mcheck.wfu; end
	%if isfield(mcheck,'M') & isfield(mcheck,'mat') & isequal(mcheck.M,mcheck.mat)
	%	V.wfu.spm99norm = 1;
	%	V.wfu.M = mcheck.M;
	%	V.wfu.mat = mcheck.mat;
	%	V.wfu.spm99header = 0;

		%mat = V.mat;
		%dims = V.dim;
		%if size(dims) < 4, dims = [dims 1]; end;
		%bb = diag(V.mat)' .* dims;
		%bb = abs(bb(1:3));
		%tol = 5;
		%td = [182 218 182]; 
		%not_normalized = sum(floor(abs(bb - td)/tol));
		%normalized = 0;
		%if not_normalized == 0, normalized = 1; end;
		%V.wfu.M = mcheck.M;
		%V.wfu.mat = mcheck.mat;
		%V.wfu.normalized = normalized;
	%end
end

if exist(mfname)~=2
	[normalized,mat,M,spm99_norm] = wfu_isnormalized(fname,V);
	V.wfu.M = M;
	V.wfu.mat = mat;
	V.wfu.normalized = normalized;
	V.wfu.spm99norm = spm99_norm;
	V.wfu.spm99header = spm99_norm;
	if normalized
		if ~isequal(V.mat,mat)
			V.mat = mat;
			%disp(['wfu_spm_vol_ana mat update ' fname]);
			%save(fname,'mat','M');
			%disp(['Saved ' fname]);
		end
	end
end;

