function [smooth_files] = ICC_smooth(file_to_smooth,kernel)
%batch that smooths files_to_smooth to a gaussian with kernel=[k1, k2, k3]; 
%____________________________________________________________________________

global defaults
spm_defaults;

if nargin<1
    [files,sts] =spm_select(Inf,'image','images to smooth...');          
    nscans=size(files);
    nscans=nscans(1);
    file_to_smooth='';
     
    for sc=1:nscans;
       [sd f ex]=fileparts(files(sc,:));
       file_to_smooth=strvcat(file_to_smooth,[sd '/' f '.img']);       
    end;
    
end;

if nargin<1
   kernel = spm_input('smooth kernel', 1,'e',[7 7 7],NaN);
end;

nscans=size(file_to_smooth);
nscans=nscans(1);
smooth_files='';
spm_progress_bar('Init',nscans,'Smoothing','Volumes Complete');
for sc=1:nscans;
    fprintf('...smoothing image')
    fprintf('%5.1f \n', sc)
    [sd f ex]=fileparts(file_to_smooth(sc,:)); 
    U =[sd '/s' f '.img'];         
    spm_smooth(file_to_smooth(sc,:),U,kernel);
    smooth_files=strvcat(smooth_files,U);
    spm_progress_bar('Set',sc)
end;

return
