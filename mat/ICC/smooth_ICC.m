function [results]=smooth_ICC()
%this function calculates brain and network ICCs for different smoothing kernels
%kernel_variation is the sizes of the smothing, i.e 
%kernel_variation=[1 2 3] for which kernel=[1*voxel_size 2*voxel size 3*voxelsize]
%voxel_size is the size of the original contrast images.
%
%__________________________________________________________________________
global defaults
spm_defaults;

th=spm_input('network threshold',1,'e',3.5,NaN); %important to find maxima

sel1=['']; 
    
[root,sts1] = spm_select(Inf,'dir','Select working directory...',sel1, ...
                         pwd,'.*',[]);
cd(root); 


[files,sts] =spm_select(Inf,'image','images...','',pwd,'^.*\.img$');          
nscans=size(files);
nscans=nscans(1);
Files='';
masked_Files=''; 
masked_smooth_Files='';

for sc=1:nscans;
   [sd f ex]=fileparts(files(sc,:));   
    Files=strvcat(Files,[sd '/' f '.img']);
    masked_Files=strvcat(masked_Files,[sd '/m_' f '.img']);      
    masked_smooth_Files=strvcat(masked_smooth_Files,[sd '/m_sm_' f '.img']);
end;

kernel_variation=spm_input('times vox size',2,'e',[2 4 6],NaN);

nsessions=spm_input('number of sessions',3,'e',2,NaN);

mask_img(Files);
           
%define one sample t-test
delete([pwd, '/SPM.mat']);


%voxel dimensions for smoothing
V=spm_vol(files(1,:));

vx=abs(V.mat(1,1));
vy=abs(V.mat(2,2));
vz=abs(V.mat(3,3));
l=kernel_variation;
for n = 1:size(l,2);
    
    kernel=[vx*l(n),vy*l(n),vz*l(n)]   

    delete([pwd, '/mask*']);
    %smooth
    [smooth_files] = ICC_smooth(masked_Files,kernel); 
    
    fprintf('...masking images. \n')
    
    %mask
    mask_img(smooth_files,[pwd,'/','Mask01.img']);
    
    %calculate group t map
    if exist([pwd '/SPM.mat'])==0
       spm_spm_ui;
    end
    
    temp=load('SPM');    
    defaults.modality='FMRI';
 
    temp_SPM=spm_spm(temp.SPM);
       
    contr.name='up';
    contr.vect=1;
    con_files=contrasts('SPM.mat',contr);
    
    fprintf('...calculating ICCs. \n')
    ICC_maps(masked_smooth_Files,nsessions);
      
        
    act=[pwd,'/spmT_0001.img'];    
    net= act;
    res= [pwd,'/ICC_2A_con.img'];

    [datreg, datregn, datregnn] = ICC_network(th,net, act, res);
        
    %network
    D1=datregn(:,1);
    D2=datregn(:,2);
    D1=D1(D2~=0);
    D2=D2(D2~=0);
                        
    sD2=sort(D2);
    Dicc=D2;
    sDicc=sort(Dicc);
    medianN1=sDicc(floor((length(Dicc)+1)/2));
    N1cci(1)=sDicc(floor((length(Dicc)+1)/2  -sqrt(length(Dicc))/2*2.575));
    N1cci(2)=sDicc(floor((length(Dicc)+1)/2  +sqrt(length(Dicc))/2*2.575));
    NetStErr = abs(N1cci(1)-N1cci(2))/2;
    sigmaNet = NetStErr/2.575;
        
    kernel_iccn(n)=medianN1;
    kernel_err_iccn(n)=NetStErr;
               
               
    %brain volume
    D1=datreg(:,1);
    D2=datreg(:,2);
    D1=D1(D2~=0);
    D2=D2(D2~=0);
            
    Dicc=D2;
    sDicc=sort(Dicc);
    medianN1=sDicc(floor((length(Dicc)+1)/2));
    N1cci(1)=sDicc(floor((length(Dicc)+1)/2  -sqrt(length(Dicc))/2*2.575));
    N1cci(2)=sDicc(floor((length(Dicc)+1)/2  +sqrt(length(Dicc))/2*2.575));
    NetStErr = abs(N1cci(1)-N1cci(2))/2;
    sigmaNet = NetStErr/2.575;
            
    kernel_iccb(n)=medianN1;
    kernel_err_iccb(n)=NetStErr;  
    
end;

delete([pwd, '/sm*']);
delete([pwd, '/m_sm*']);


figure;
set(gcf, 'color', 'white');
errorbar([kernel_variation' kernel_variation'], [kernel_iccb' kernel_iccn'], [kernel_err_iccb' kernel_err_iccn'])
legend('Brain', 'network', 'Location', 'SouthEastOutside');
ylabel('median ICC'); xlabel('FWHM (times voxel size)');

results={};
results=setfield(results, 'brain',[kernel_iccb' ]);
results=setfield(results, 'network',[kernel_iccn' ]);
results=setfield(results, 'FWHM', [kernel_variation'])