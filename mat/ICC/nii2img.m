function nii2img(Files, ref_img) 
%this function converts nii images to img images using imcalc. 
%It uses a reference image to reslice into its format.

global defaults
spm_defaults;

if nargin<1
    [files,sts] =spm_select(Inf,'image','select images...');          
    nscans=size(files);
    nscans=nscans(1);
    Files='';
    imgfiles = '';
     
    for sc=1:nscans;
       [sd f ex]=fileparts(files(sc,:));
       Files=strvcat(Files,[sd '/' f ex]); 
       imgfiles=strvcat(imgfiles,[sd '/' f '.img']); 
    end;
end

if nargin<2
    [f_act,sts] =spm_select(1,'image','reference image...','', pwd,'^.*\.img$');      
    [sd f ex]=fileparts(f_act);
    ref_img=[sd '/' f '.img'];  
end
    spm_imcalc_ui(ref_img,[pwd '/output.img'],'(i1<-Inf)+1');
    
    
for image=1:size(Files,1);
    Files(image,:)
    [sd f ex]=fileparts(Files(image,:));
    imcal_input=strvcat([pwd '/output.img'], Files(image,:));
    spm_imcalc_ui(imcal_input,[sd '/' f '.img'],'i1.*i2');
end;
delete([pwd '/output.img']);
delete([pwd '/output.hdr']);

fprintf('**************** \n')

fprintf('computing done \n')

