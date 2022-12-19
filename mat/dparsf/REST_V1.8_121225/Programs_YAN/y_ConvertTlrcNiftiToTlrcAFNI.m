function y_ConvertTlrcNiftiToTlrcAFNI(TlrcNiftiFileName);
% FORMAT function y_ConvertTlrcNiftiToTlrcAFNI(TlrcNiftiFileName);
% Convert the NIfTI file in talairach space into .HEAD/.BRIK format which can be displayed with AFNI in Talairach View.
% This program is for the combination usage of AFNI and REST/DPARSF. E.g. for brain tumor patients which can not perform normalization with SPM:
% 1. Use DPARSF to complete the pre-normalization steps: DICOM->NIfTI, Slice Timing, Realign, sturctural T1 .hdr/img coregister to the space of realigned mean functional image.
% 2. Use AFNI's command '3dWarp -deoblique' and '3drefit -markers' to convert the coregistered structural T1 .hdr/img into structural .HEAD/BRIK pair.
% 3. Use AFNI's command '3dTcat' to convert the realigned EPI .hdr/img into functional .HEAD/BRIK pair.
% 4. Use AFNI to manually normalize the structural .HEAD/BRIK into talairach coordinate system. Then use 'Define Datamode'->'Warp Ulay on Demand' to save and resample the structural .HEAD/BRIK and functional .HEAD/BRIK into '+tlrc.HEAD/BRIK' files in talairach space.
% 5. Use AFNI's command '3dAFNItoNIFTI' to convert functional '+tlrc.HEAD/BRIK' into 4d .nii files. Then use REST->Utilities->NIfTI .nii to NIfTI pairs to convert the 4d .nii into 3d .hdr/img.
% 6. Use DPARSF to perform the following analysis such as 'smooth->detrend->filter->ALFF,mALFF' based on the 3d .hdr/img files.
% 7. Use REST or SPM to perform the Statistical analysis.
% 8. Use the current program 'y_ConvertTlrcNiftiToTlrcAFNI' to convert the statistical result NIfTI file (which is in talairach space) into .HEAD/.BRIK format while keeping a Talairach View.
% 9. Use AFNI to view the results and generate the cluster report.
%   Input:
%     TlrcNiftiFileName - The file name of NIfTI file in talairach space.
%   Output:
%     TlrcNiftiFileName +tlrc.HEAD/BRIK - The .HEAD/.BRIK file which can be displayed with AFNI in Talairach View.
%___________________________________________________________________________
% Written by YAN Chao-Gan 101007.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% ycg.yan@gmail.com

[Path, FileName, extn] = fileparts(TlrcNiftiFileName);
OldDir=pwd;
if ~isempty(Path)
    cd(Path);
end

[Outdata,Header]= rest_ReadNiftiImage([FileName,'.img']);
if Header.mat(1,1)>0
    Outdata = flipdim(Outdata,1);
    Header.mat(1,:) = -1*Header.mat(1,:);
end
if Header.mat(2,2)>0
    Outdata = flipdim(Outdata,2);
    Header.mat(2,:) = -1*Header.mat(2,:);
end
if Header.mat(3,3)<0
    Outdata = flipdim(Outdata,3);
    Header.mat(3,:) = -1*Header.mat(3,:);
end
rest_WriteNiftiImage(Outdata,Header,['RAI_',FileName]);
try
    eval(['!3dcopy ',['RAI_',FileName,'.hdr'],' ',[FileName,'+tlrc']])
catch
    disp('Can not found the AFNI command ''3dcopy'', Please re-run the program in environment with AFNI.');
end

cd (OldDir);
            