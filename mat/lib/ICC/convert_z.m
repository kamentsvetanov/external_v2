function convert_z(Files)
%convert correlation (ICC) maps into fisher's z.
%
%__________________________________________________________________________

global defaults
spm_defaults;

if nargin<1
    [files,sts] =spm_select(Inf,'image','images...');          
    nscans=size(files);
    nscans=nscans(1);
    Files='';
     
    for sc=1:nscans;
       [sd f ex]=fileparts(files(sc,:));
       Files=strvcat(Files,[sd '/' f '.img']);       
    end;
    
end



V2=spm_vol(Files);
V1=V2;
length(V2);

%create hdrs
for k=1:length(V2);
       [sd f ex]=fileparts(Files(k,:));
       V1(k).fname = [sd,'/z_' f '.img'];      
       V1(k)  = spm_create_vol(V1(k));       
end;



% The main Loop over planes...
for i=1:V2(1).dim(3),

    % Read a plane for each image...
    M = spm_matrix([0 0 i]);
      
   
    for k=1:length(V2),     
    
        dat2(:,:) = spm_slice_vol(V2(k),M,V2(k).dim(1:2),0);
  
        dat(:,:) =log(abs((1+dat2(:,:))./(1-dat2(:,:)) )  )./2;
        
        V1(k) = spm_write_plane(V1(k),dat(:,:),i);    
    end;
end;  
    

fprintf('**************** \n')

fprintf('computing done \n')

return
