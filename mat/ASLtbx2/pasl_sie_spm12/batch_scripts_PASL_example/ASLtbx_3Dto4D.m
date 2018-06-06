% use the following code to convert 3D images to 4D images
imgfiles=spm_select;
if rem(size(imgfiles,1),2)==0
    fprintf('You only selected an even number of images! \n');
    %return -1;
end
v=spm_vol(imgfiles(1,:));
dat=spm_read_vols(v);
v.fname=fullfile(spm_str_manip(imgfiles(1,:), 'h'), 'M0.nii');
v=spm_write_vol(v, dat);
v=spm_vol(imgfiles(2:end,:));
file4Dname=fullfile(spm_str_manip(imgfiles(1,:), 'h'), ['PASL.nii']);
spm_file_merge(v,file4Dname,0);
% delete the original 3D files
for i=1:size(imgfiles,1)
    delete(imgfiles(i,:));
end