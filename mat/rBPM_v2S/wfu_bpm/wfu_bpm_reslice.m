function outName = spm_bpm_reslice(P,outDir)
% this is the spm function spm_reslice that was slightly modified.
fname   = 'mask';
outName = fullfile(outDir,[fname,'.img']);

flags = struct('interp',1,'mask',0,'mean',0,'which',1,'wrap',[0 0 0]');
if ~finite(flags.interp), % Use Fourier method
	% Check for non-rigid transformations in the matrixes
	for i=1:prod(size(P)),
		pp = P(1).mat\P(i).mat;
		if any(abs(svd(pp(1:3,1:3))-1)>1e-7),
			fprintf('\n  Zooms  or shears  appear to  be needed');
			fprintf('\n  (probably due to non-isotropic voxels).');
			fprintf('\n  These  can not yet be  done  using  the');
			fprintf('\n  Fourier reslicing method.  Switching to');
			fprintf('\n  7th degree B-spline interpolation instead.\n\n');
			flags.interp = 7;
			break;
		end;
	end;
end;

nread = prod(size(P));
if ~flags.mean,
	if flags.which == 1, nread = nread - 1; end;
	if flags.which == 0, nread = 0; end;
end;
spm_progress_bar('Init',nread,'Reslicing','volumes completed');

tiny = 5e-2; % From spm_vol_utils.c

[x1,x2] = ndgrid(1:P(1).dim(1),1:P(1).dim(2));

PO    = P;
nread = 0;
d     = [flags.interp*[1 1 1]' flags.wrap(:)];

for i = 1:prod(size(P)),

	if (i>1 & flags.which==1) | flags.which==2, write_vol = 1; else, write_vol = 0; end;
	if write_vol | flags.mean,                   read_vol = 1; else   read_vol = 0; end;

	if read_vol,
		if write_vol,
			VO         = P(i);
			VO.fname   = outName;
			VO.dim     = [P(1).dim(1:3) P(i).dim(4)];
			VO.mat     = P(1).mat;
			VO.descrip = 'spm - realigned';
			VO         = spm_create_vol(VO);
		end;

		if ~finite(flags.interp),
			v = abs(kspace3d(spm_bsplinc(P(i),[0 0 0 ; 0 0 0]'),P(1).mat\P(i).mat));
			for x3 = 1:P(1).dim(3),
				if flags.mean,
					Integral(:,:,x3) = Integral(:,:,x3) + ...
						nan2zero(v(:,:,x3).*getmask(inv(P(1).mat\P(i).mat),x1,x2,x3,P(i).dim(1:3),flags.wrap));
				end;
				if flags.mask, tmp = v(:,:,x3); tmp(msk{x3}) = NaN; v(:,:,x3) = tmp; end;
				if write_vol,  VO = spm_write_plane(VO,v,x3); end;
			end;
		else,
			C = spm_bsplinc(P(i), d);
			for x3 = 1:P(1).dim(3),

				[tmp,y1,y2,y3] = getmask(inv(P(1).mat\P(i).mat),x1,x2,x3,P(i).dim(1:3),flags.wrap);
				v              = spm_bsplins(C, y1,y2,y3, d);
				% v(~tmp)        = 0;

				if flags.mean, Integral(:,:,x3) = Integral(:,:,x3) + nan2zero(v); end;

				if write_vol,
					if flags.mask, v(msk{x3}) = NaN; end;
					VO = spm_write_plane(VO,v,x3);
				end;
			end;
		end;
%		if write_vol, VO = spm_close_vol(VO); end;
		if write_vol
            if exist('spm_close_vol')
                VO = spm_close_vol(VO);
            end;
        end
		nread = nread + 1;
	end;
	spm_progress_bar('Set',nread);
end;


spm_figure('Clear','Interactive');
return;
%_______________________________________________________________________

%_______________________________________________________________________
function v = kspace3d(v,M)
% 3D rigid body transformation performed as shears in 1D Fourier space.
% FORMAT v1 = kspace3d(v,M)
% Inputs:
% v - the image stored as a 3D array.
% M - the rigid body transformation matrix.
% Output:
% v - the transformed image.
%_______________________________________________________________________

[S0,S1,S2,S3] = shear_decomp(M);

d  = [size(v) 1 1 1];
g = 2.^ceil(log2(d));
if any(g~=d),
	tmp = v;
	v   = zeros(g);
	v(1:d(1),1:d(2),1:d(3)) = tmp;
	clear tmp;
end;

% XY-shear
tmp1 = -sqrt(-1)*2*pi*([0:((g(3)-1)/2) 0 (-g(3)/2+1):-1])/g(3);
for j=1:g(2),
	t        = reshape( exp((j*S3(3,2) + S3(3,1)*(1:g(1)) + S3(3,4)).'*tmp1) ,[g(1) 1 g(3)]);
	v(:,j,:) = real(ifft(fft(v(:,j,:),[],3).*t,[],3));
end;

% XZ-shear
tmp1 = -sqrt(-1)*2*pi*([0:((g(2)-1)/2) 0 (-g(2)/2+1):-1])/g(2);
for k=1:g(3),
	t        = exp( (k*S2(2,3) + S2(2,1)*(1:g(1)) + S2(2,4)).'*tmp1);
	v(:,:,k) = real(ifft(fft(v(:,:,k),[],2).*t,[],2));
end;

% YZ-shear
tmp1 = -sqrt(-1)*2*pi*([0:((g(1)-1)/2) 0 (-g(1)/2+1):-1])/g(1);
for k=1:g(3),
	t        = exp( tmp1.'*(k*S1(1,3) + S1(1,2)*(1:g(2)) + S1(1,4)));
	v(:,:,k) = real(ifft(fft(v(:,:,k),[],1).*t,[],1));
end;

% XY-shear
tmp1 = -sqrt(-1)*2*pi*([0:((g(3)-1)/2) 0 (-g(3)/2+1):-1])/g(3);
for j=1:g(2),
	t        = reshape( exp( (j*S0(3,2) + S0(3,1)*(1:g(1)) + S0(3,4)).'*tmp1) ,[g(1) 1 g(3)]);
	v(:,j,:) = real(ifft(fft(v(:,j,:),[],3).*t,[],3));
end;

if any(g~=d), v = v(1:d(1),1:d(2),1:d(3)); end;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function [S0,S1,S2,S3] = shear_decomp(A)
% Decompose rotation and translation matrix A into shears S0, S1, S2 and
% S3, such that A = S0*S1*S2*S3.

A0 = A(1:3,1:3);
if any(abs(svd(A0)-1)>1e-7), error('Can''t decompose matrix'); end;


t  = A0(2,3); if t==0, t=eps; end;
a0 = pinv(A0([1 2],[2 3])')*[(A0(3,2)-(A0(2,2)-1)/t) (A0(3,3)-1)]';
S0 = [1 0 0; 0 1 0; a0(1) a0(2) 1];
A1 = S0\A0;  a1 = pinv(A1([2 3],[2 3])')*A1(1,[2 3])';  S1 = [1 a1(1) a1(2); 0 1 0; 0 0 1];
A2 = S1\A1;  a2 = pinv(A2([1 3],[1 3])')*A2(2,[1 3])';  S2 = [1 0 0; a2(1) 1 a2(2); 0 0 1];
A3 = S2\A2;  a3 = pinv(A3([1 2],[1 2])')*A3(3,[1 2])';  S3 = [1 0 0; 0 1 0; a3(1) a3(2) 1];

s3 = A(3,4)-a0(1)*A(1,4)-a0(2)*A(2,4);
s1 = A(1,4)-a1(1)*A(2,4);
s2 = A(2,4);
S0 = [[S0 [0  0 s3]'];[0 0 0 1]];
S1 = [[S1 [s1 0  0]'];[0 0 0 1]];
S2 = [[S2 [0 s2  0]'];[0 0 0 1]];
S3 = [[S3 [0  0  0]'];[0 0 0 1]];
return;
%_______________________________________________________________________

%_______________________________________________________________________
function [Mask,y1,y2,y3] = getmask(M,x1,x2,x3,dim,wrp)
tiny = 5e-2; % From spm_vol_utils.c
y1   = M(1,1)*x1+M(1,2)*x2+(M(1,3)*x3+M(1,4));
y2   = M(2,1)*x1+M(2,2)*x2+(M(2,3)*x3+M(2,4));
y3   = M(3,1)*x1+M(3,2)*x2+(M(3,3)*x3+M(3,4));
Mask = logical(ones(size(y1)));
if ~wrp(1), Mask = Mask & (y1 >= (1-tiny) & y1 <= (dim(1)+tiny)); end;
if ~wrp(2), Mask = Mask & (y2 >= (1-tiny) & y2 <= (dim(2)+tiny)); end;
if ~wrp(3), Mask = Mask & (y3 >= (1-tiny) & y3 <= (dim(3)+tiny)); end;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function PO = prepend(PI,pre)
[pth,nm,xt,vr] = fileparts(deblank(PI));
PO             = fullfile(pth,[pre nm xt vr]);
return;
%_______________________________________________________________________

%_______________________________________________________________________
function vo = nan2zero(vi)
vo = vi;
vo(~finite(vo)) = 0;
return;
%_______________________________________________________________________

%_______________________________________________________________________

