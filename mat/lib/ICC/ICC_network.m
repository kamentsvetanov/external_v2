function [datreg, datregn, datregnn] = ICC_network(th,network_file, file1, file2)
%voxel values of results_file.
% 
%th= threshold for the network_file
%network_file= region of interest, thresholded by th, of a ROI mask
%file1= data of the first image 
%file2 = data of the second image
%
%
%datreg= two column matrix. First column: data of file1. Second
%column: data of file2. Rows: all voxels across the image. 
%datregn= two column matrix. Rows: all voxels across the network
%datregn= two column matrix. Rows: all voxels outside the network and
%inside the brain volume
%____________________________________________________________________________

global defaults
spm_defaults;


if nargin<1
    th=spm_input('threshold',1,'e',[4],NaN);
end;

if nargin<2
    [file,sts] =spm_select(1,'image','network...');      
    [sd f ex]=fileparts(file);
    network_file=([pwd,'/',f,ex]);
end;

if nargin<3
    [file,sts] =spm_select(1,'image','first image...');      
    [sd f ex]=fileparts(file);    
    file1=([pwd,'/',f,ex]);
end;


if nargin<4
    [file,sts] =spm_select(1,'image','seond image...');      
    [sd f ex]=fileparts(file);
    file2=([pwd,'/',f,ex]);
end;

[root f ex]=fileparts(network_file);
root=[root,'/'];

V1=spm_vol(file1);
V2=spm_vol(file2);
Vm=spm_vol(network_file);


% The main Loop over planes...
for i=1:V1.dim(3),
  fprintf('...computing plane.')
  fprintf('%5.1f \n', i)

% Read a plane for each image...
  M = spm_matrix([0 0 i]);
  
  dat1(:,:,i) = spm_slice_vol(V1,M,V1.dim(1:2),0);     
  dat2(:,:,i) = spm_slice_vol(V2,M,V2.dim(1:2),0);
  datm(:,:,i) = spm_slice_vol(Vm,M,Vm.dim(1:2),0);
  dat1(dat1==0)=NaN;
  dat2(dat2==0)=NaN;
    
 %masks 
  Mask(:,:,i) = datm(:,:,i)>th;  %select the network of high activation
  Mask2(:,:,i) = ~Mask(:,:,i);  
  Mask3(:,:,i) = ~isnan(dat2(:,:,i));
  Mask2(:,:,i) = Mask2(:,:,i).*Mask3(:,:,i);

  
  dat_farc_net(:,:,i) =dat2(:,:,i).*Mask(:,:,i);  
  dat_net(:,:,i) =dat1(:,:,i).*Mask(:,:,i);
  
  dat_farc_nonet(:,:,i) =dat2(:,:,i).*Mask2(:,:,i); 
  dat_nonet(:,:,i) =dat1(:,:,i).*Mask2(:,:,i);  

  dat_farc_net(dat_farc_net==0)=NaN;
  dat_net(dat_net==0)=NaN;
  dat_farc_nonet(dat_farc_nonet==0)=NaN;   
  dat_nonet(dat_nonet==0)=NaN;     
  
end;

D1=dat1(:);
D2=dat2(:);
D1(isnan(D2))=[];             %get rid of NaN
D2(isnan(D2))=[];
D2(isnan(D1))=[];
D1(isnan(D1))=[];             

datreg=[D1(:) D2(:)];

D1n=dat_net(:);
D2n=dat_farc_net(:);
D1n(isnan(D2n))=[];
D2n(isnan(D2n))=[];
D2n(isnan(D1n))=[];
D1n(isnan(D1n))=[];    
datregn=[D1n(:) D2n(:)];

D1nn=dat_nonet(:);
D2nn=dat_farc_nonet(:);
D1nn(isnan(D2nn))=[];
D2nn(isnan(D2nn))=[];
D2nn(isnan(D1nn))=[];
D1nn(isnan(D1nn))=[];   
datregnn=[D1nn(:) D2nn(:)];

return;