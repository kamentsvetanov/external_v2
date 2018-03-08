function y_ChangeBVector(BVector_filename)
% FORMAT ChangeBVector(BVector_filename)
%   Input:
%     BVector_filename - The raw b vector created by MRIcroN's dcm2nii
%   Output:
%     ForDTIStudioBVector_filename - b vector suitable for DTI studio
%___________________________________________________________________________
% Written by YAN Chao-Gan 100822.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% ycg.yan@gmail.com

if nargin==0
    [filename, pathname] = uigetfile('*.*', 'Select the raw b vector file');
    BVector_filename = fullfile(pathname, filename);
end
[pth,name,ext]=fileparts(BVector_filename);
ForDTIStudioBVector_filename=fullfile(pth, strcat('ForDTIStudio_', name,ext));
disp(['The resulted b vector file for DTI studio has been saved as: ' ForDTIStudioBVector_filename ]);
if exist (ForDTIStudioBVector_filename)
    delete(ForDTIStudioBVector_filename)
end

Bvec=load(BVector_filename);
Bvec=Bvec';
fid = fopen(ForDTIStudioBVector_filename,'at+');
for j=1:size(Bvec,1)
    fprintf(fid,'%d%s%2.4f%s%2.4f%s%2.4f\n',j-1,': ',Bvec(j,1),', ',Bvec(j,2),', ',Bvec(j,3));
end
fclose(fid);

