function mask_img(Files,mFiles)
%mask Files with a mask selected by the user or with Mask01.img, created by 
%the program and is the mask of voxels that have data in all the selected images. 
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

[sd f ex]=fileparts(Files(1,:));
cd(sd);
V2=spm_vol(Files);
V2m=spm_vol(Files);


for k=1:length(V2),
    [sd f ex]=fileparts(Files(k,:));
    V2m(k).fname=[sd '/m_' f '.img'];
    if V2(1).dt(1)~=16;        
       V2m(k).dt=[16 1]; % float32 data type to support NaN
       V2m(k).private.dat.dtype='FLOAT32-BE';
    end
    V2m(k)  = spm_create_vol(V2m(k));
end;



%ask for explicit mask
if nargin<2
   msk = spm_input('explict mask?',1,'b','yes|no',['y' 'n'], 2);

   if msk ~='n'
        [f_act,sts] =spm_select(1,'image','mask image...','', pwd,'^.*\.img$');      
        [sd f ex]=fileparts(f_act);
        mFiles=[sd '/' f '.img'];  
        
        dim =spm_input('dim(Mask)=dim(img)?',2,'b','yes|no',['y' 'n'], 1);
       

        if dim~='y'
               
            [f_act,sts] =spm_select(1,'image','reference image...','', pwd,'^.*\.img$');      
            [sd f ex]=fileparts(f_act);
            ref_img=[sd '/' f '.img']; 
        
            spm_imcalc_ui(ref_img,[pwd '/output.img'],'(i1<-Inf)+1');
                    
            [sd f ex]=fileparts(mFiles);
            imcal_input=strvcat([pwd '/output.img'], mFiles);
            spm_imcalc_ui(imcal_input,[sd '/' f '.img'],'i1.*i2');
            
            delete([pwd '/output.img']);
            delete([pwd '/output.hdr']);  
            
        end
        %copy mask to Mask01.img with appropriate data type
        VmFile = spm_vol(mFiles);
            
        Vm=V2m(1);%data type float32
        Vm.fname = [pwd,'/','Mask01.img'];  
        Vm  = spm_create_vol(Vm);
                   
        for i=1:V2(1).dim(3), %each plane   
            M = spm_matrix([0 0 i]);
            datmask(:,:) = spm_slice_vol(VmFile,M,VmFile.dim(1:2),0);
            Vm = spm_write_plane(Vm,datmask(:,:),i);     
        end;           
     
        
   else %/create overllap mass
           fprintf('creating mask... \n')
           Vm=V2m(1);
           Vm.fname = [pwd,'/','Mask01.img'];  
           Vm  = spm_create_vol(Vm);
   
           for i=1:V2(1).dim(3), %each plane
   
                % Read a plane for each image...
                M = spm_matrix([0 0 i]);
                datmask=ones(Vm.dim(1),Vm.dim(2));
            
                for k=1:length(V2),  %each volume   
        
                    dat2(:,:) = spm_slice_vol(V2(k),M,V2(k).dim(1:2),0);
                    datmask(:,:) =datmask(:,:).*dat2(:,:);
           
                end;
    
                %store as binary   
                nn=isnan(datmask);
                z=datmask==0;
                o=~isnan(datmask) & datmask~=0;
                
                datmask(nn)=0;
                datmask(z)=0;
                datmask(o)=1;
                
                Vm = spm_write_plane(Vm,datmask(:,:),i);     
               
           end;
        
           mFiles=[pwd,'/','Mask01.img'];
   
   end;

end

 
mask_file = mFiles;

V1=spm_vol(mask_file);
fprintf('masking...\n')

% The main Loop over planes...
for i=1:V1(1).dim(3),

    fprintf('...computing plane.')
    fprintf('%5.1f \n', i)
    % Read a plane for each image...
    M = spm_matrix([0 0 i]);
      
    dat1(:,:) = spm_slice_vol(V1,M,V1.dim(1:2),0);   
    dat1(dat1==0)=NaN;
    
    for k=1:length(V2),     
    
        dat2(:,:) = spm_slice_vol(V2(k),M,V2(k).dim(1:2),0);
  
        dat(:,:) =dat2(:,:).*dat1(:,:);
        
        V2m(k) = spm_write_plane(V2m(k),dat(:,:),i);   
        
    end;
  
end;  
fprintf('**************** \n')

fprintf('masking done \n')

