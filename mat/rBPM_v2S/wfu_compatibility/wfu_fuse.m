function outfile = wfu_fuse(anatomic, tmap, threshold)
%-----------------------------------------------------------------------
%This program will take an anatomic and a Tmap, and create a fused analyze file
%The Tmap can be created using SPM write_filtered or Save in the Results GUI in SPM
%Resampling is handled using wfu_findobject2target
%It will also copy any existing .dicom or .info file from the anatomic
%JAM 10-27-05
%----------------------------------------------------------------------


if ~exist('threshold'), threshold = 0; end;
V = spm_vol(anatomic);
Vt = spm_vol(tmap);
%------------------------
%Make sure the images are in the same space
%------------------------
if ~isequal(V.dim(1:3), Vt.dim(1:3))
	object = tmap;
	target = anatomic;
	[MT,object2mni,target2mni] = wfu_findobject2target(object, target,1);
	[pth2, nam2, ext2] = fileparts(tmap);
	tmap = fullfile(pth2,['r' nam2 '.img']);
	Vt = spm_vol(tmap);
end


image = spm_read_vols(V);
t = spm_read_vols(Vt);
points = find(t > threshold);
length(points);

%--------------------------------------------------
%Set the surviving points to maxval from anatomic + the t-score
%--------------------------------------------------
maxval = max(reshape(image,[1 prod(size(image))]));
image(points) = t(points) + maxval;
Vout = V;
[pth, nam, ext] = fileparts(anatomic);
[pth2, nam2, ext2] = fileparts(tmap);
outfile = fullfile(pth,[nam '_' nam2 '.img']);
Vout.fname = outfile;         
spm_write_vol(Vout ,image);

%-----------------------------------------
%Copy any existing .dicom or .info file
%-----------------------------------------
dicomfile = fullfile(pth,[nam '.dicom']);
infofile = fullfile(pth,[nam '.info']);
[pth3,nam3,ext3] = fileparts(outfile);
if exist(dicomfile,'file')
	ndicom = fullfile(pth3,[nam3 '.dicom']);
	if exist(ndicom,'file'), delete(ndicom); end
	copyfile(dicomfile,ndicom,'f');
end
if exist(infofile,'file')
	ninfo = fullfile(pth3,[nam3 '.info']);
	if exist(ninfo,'file'), delete(ninfo); end
	copyfile(infofile,ninfo,'f');
end

