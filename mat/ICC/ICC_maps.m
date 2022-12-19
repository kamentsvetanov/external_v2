function ICC_maps(files_test, nsessions) 
%calculates the reliability coefficient of a test (first 1:n-images) 
%re-test (next n:2n-images) study, and successive sessions input in simmilar maner.
%
%outputs are image files with ICC maps 
%(ICC) Shrout & Fleiss psych. bull. 1979, vol 86, No 2, 420.  
%(case 2A -absolute agreement takes ito account session variation) Geon-Ho
%           et al Radiology  2005, vol 234, No 3, 909.(absolute agreement ICC, 
%(ICC_2A_con -consistency agreement) McGraw & Wong psych. meths. 1996, vol 1, No 1, 30.  
%(ICC_z) -fisher's z trasform of ICC_2A_con). 
%(BMS) -between subject sum of squares.
%(WMS) -within subject sum of squares. (one way anova)
%(JMA) -session sum of squares. (two way anova)
%(EMS) -error sum of squares. (two way anova)
%____________________________________________________________________________


global defaults
spm_defaults;

sel1=['']; 
    
%[root,sts1] = spm_select(Inf,'dir','Select working directory...',sel1, ...
%                         pwd,'.*',[]);
root=[pwd,'/'];
cd(root); 


if nargin<1
    [files,sts] =spm_select(Inf,'image','images for icc...');          
    nscans=size(files);
    nscans=nscans(1);
    files_test='';
     
    for sc=1:nscans;
       [sd f ex]=fileparts(files(sc,:));
       files_test=strvcat(files_test,[sd '/' f '.img']);       
    end;
    
end

if nargin<2
   nsessions=spm_input('No. of sessions',1,'e',2,NaN);
end;


%write full path in filenames 
nsamples=size(files_test,1);
nsubjects=nsamples/nsessions;


% Map images
V=spm_vol(files_test);

VICC = V(1);
VICC_2A = V(1);
VICC_2A_con = V(1);
VICC_z = V(1);

VBMS = V(1);
VWMS = V(1);
VJMS = V(1);
VEMS = V(1);

%create hdrs
VICC.fname = [root,'ICC.img'];      
VICC  = spm_create_vol(VICC);

VICC_2A.fname = [root,'ICC_2A.img'];      
VICC_2A  = spm_create_vol(VICC_2A);
 
VICC_2A_con.fname = [root,'ICC_2A_con.img'];      
VICC_2A_con  = spm_create_vol(VICC_2A_con);

VICC_z.fname = [root,'ICC_Z.img'];      
VICC_z  = spm_create_vol(VICC_z);


VBMS.fname = [root,'BMS.img'];
VBMS  = spm_create_vol(VBMS);
VWMS.fname = [root,'sigma2w_WMS.img'];
VWMS  = spm_create_vol(VWMS);
VJMS.fname = [root,'JMS.img'];
VJMS  = spm_create_vol(VJMS);
VEMS.fname = [root,'sigma2e_EMS.img'];
VEMS  = spm_create_vol(VEMS);


% The main Loop over planes...
for i=1:V(1).dim(3),
  fprintf('...computing plane.')
  fprintf('%5.1f \n', i)

% Read a plane for each image...
  M = spm_matrix([0 0 i]);
  

%label data by subject and sessions
  for sess=0:nsessions-1,
      for sub=1:nsubjects,
          sample=floor(sub+sess*(nsubjects));
          dat(:,:,sub,sess+1) = spm_slice_vol(V(sample),M,V(1).dim(1:2),0); 
      end;
  end;
  
  
  grandmean=zeros(V(1).dim(1),V(1).dim(2));  
  for sub=1:nsubjects,     
      for sess=1:nsessions,
      grandmean(:,:)= grandmean(:,:) + dat(:,:,sub,sess);
      end
      
  end;
  grandmean(:,:)=grandmean(:,:)./nsamples;
  
  
  
  sessionmean= zeros(V(1).dim(1),V(1).dim(2),nsessions);
  for sess=1:nsessions
      for sub=1:nsubjects,  
          sessionmean(:,:,sess) = sessionmean(:,:,sess) + dat(:,:,sub,sess);
      end
      sessionmean(:,:,sess)=sessionmean(:,:,sess)./nsubjects;
  end

  subjmean=zeros(V(1).dim(1),V(1).dim(2),nsubjects);
  for sub=1:nsubjects
      for sess=1:nsessions
          subjmean(:,:,sub)=subjmean(:,:,sub) + dat(:,:,sub,sess);
      end
      subjmean(:,:,sub)=subjmean(:,:,sub)./nsessions;
  end
     
  
  %between subjects mean square BMS, within subject mean square WMS
  BMS=zeros(V(1).dim(1),V(1).dim(2));
  WMS=zeros(V(1).dim(1),V(1).dim(2));  
  EMS=zeros(V(1).dim(1),V(1).dim(2));
  SST=zeros(V(1).dim(1),V(1).dim(2));
  meanbias=zeros(V(1).dim(1),V(1).dim(2));
  for sub=1:nsubjects,    
 
    BMS(:,:)= BMS(:,:) + (subjmean(:,:,sub)-grandmean(:,:)).^2;
    
    for sess=1:nsessions
        WMS(:,:)= WMS(:,:) + (dat(:,:,sub,sess)-subjmean(:,:,sub)).^2;
                     
        EMS(:,:)= EMS(:,:) + (dat(:,:,sub,sess)-subjmean(:,:,sub)-sessionmean(:,:,sess)+grandmean(:,:)).^2;
    
        SST(:,:)= SST(:,:)+  (dat(:,:,sub,sess)-grandmean(:,:)).^2;                      
    end
  end;
  
  for sess=1:nsessions
      JMS(:,:)=  (sessionmean(:,:,sess)-grandmean(:,:)).^2;
  end;
  
  %define the true value of the mean square.
  BMS(:,:)= nsessions.*BMS(:,:)./(nsubjects-1);
  WMS(:,:)= WMS(:,:)./(nsessions-1)./nsubjects;
  JMS(:,:)= nsubjects.*JMS(:,:)./(nsessions-1);
  EMS(:,:)= EMS(:,:)./(nsessions-1)./(nsubjects-1); 
  
  %(case 1) Shrout & Fleiss psych. bull. 1979, vol 86, No 2, 420.  
  ICC(:,:)=(BMS(:,:)-WMS(:,:))./(BMS(:,:)+(nsessions-1).*WMS(:,:)); 
  
  %(case 2A -consistency agreement) McGraw & Wong psych. meths. 1996, vol 1, No 1, 30.  
  ICC_2A_con(:,:)=(BMS(:,:)-EMS(:,:))./(BMS(:,:)+(nsessions-1).*EMS(:,:)); 
  
  %(case 2A -absolute agreement takes ito account session variation) Geon-Ho
  % et al Radiology  2005, vol 234, No 3, 909.
  ICC_2A(:,:)=(BMS(:,:)-EMS(:,:))./(BMS(:,:)+(nsessions-1).*EMS(:,:) + ...
                                   nsessions.* (JMS(:,:)-EMS(:,:))./nsubjects); 
  
  ICC_z(:,:)=log(abs((1+ICC_2A_con(:,:))./(1-ICC_2A_con(:,:)) )  )./2;
                                 
 
%test correct split of sums of squares:
% test=test + ...
% sum(sum(abs( ...
% (BMS(:,:)-EMS(:,:))+nsessions.* (JMS(:,:)-EMS(:,:))./nsubjects+nsessions.*EMS(:,:) - ...
% (BMS(:,:)+(nsessions-1).*EMS(:,:) +  nsessions.* (JMS(:,:)-EMS(:,:))./nsubjects)   )));
 

  VICC = spm_write_plane(VICC,100.*ICC(:,:),i); 
  VICC_2A_con = spm_write_plane(VICC_2A_con,100.*ICC_2A_con(:,:),i); 
  VICC_2A = spm_write_plane(VICC_2A,100.*ICC_2A(:,:),i);  
  VICC_z = spm_write_plane(VICC_z,ICC_z(:,:),i);  
  
  VBMS = spm_write_plane(VBMS,BMS(:,:),i); 
  VWMS = spm_write_plane(VWMS,WMS(:,:),i); 
  VJMS = spm_write_plane(VJMS,JMS(:,:),i); 
  VEMS = spm_write_plane(VEMS,EMS(:,:),i); 
  

end;
fprintf('********************** \n')
fprintf('...computing done \n.')
fprintf('explore results! \n', i)

return;

