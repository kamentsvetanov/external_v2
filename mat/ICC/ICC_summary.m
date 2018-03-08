function [ICC,ICC_2A, ICC_2A_con,p_ICC,p_ICC_2A,cv, sigmaw, sigmae]=ICC_summary(values,nsessions) 
%calculates ICC summary statistic values within ROIs (peak,mean, medians), which 
%need to be typed in or given in a file. Values must be given in a single (column) 
%vector, where the first session follows the second and so on; always preserving the
%subject order. 
%____________________________________________________________________________

if nargin<1
    read_file=spm_input('Values: file(f); type in (t)',1,'s','f',NaN);
    
    if read_file=='f'
        [file,sts] =spm_select(1,'any','file...','', pwd,'^.*\.txt$');      
        [sd f ex]=fileparts(file);
        file_values=[sd '/' f '.txt'];
        values=load(file_values);
    else
        values = spm_input('type values',1,'e','',NaN);
        values = values';
    end
    
end

if nargin<2
    nsessions = spm_input('number of sessions?',2,'e','2',NaN);
end

nsamples=size(values,1);
nsubjects=nsamples/nsessions;


%label data by subject and sessions
for sess=0:nsessions-1,
     for sub=1:nsubjects,
         sample=floor(sub+sess*(nsubjects));
         dat(sub,sess+1) = values(sample);  
     end;
 end;


  
grandmean=0;
for sub=1:nsubjects,     
    for sess=1:nsessions,
       grandmean= grandmean + dat(sub,sess);
    end
      
end;
grandmean=grandmean./nsamples;
  

sessionmean=zeros(nsessions);
for sess=1:nsessions
    for sub=1:nsubjects,  
        sessionmean(sess) = sessionmean(sess) + dat(sub,sess);
    end
    sessionmean(sess)=sessionmean(sess)./nsubjects;
end


subjmean=zeros(nsubjects);
for sub=1:nsubjects
    for sess=1:nsessions
        subjmean(sub)=subjmean(sub) + dat(sub,sess);
    end
      subjmean(sub)=subjmean(sub)./nsessions;
end

  
%between subjects mean square BMS, within subject mean square WMS
BMS=0;
WMS=0;  
EMS=0;
SST=0;
  
for sub=1:nsubjects,    
 
    BMS = BMS + (subjmean(sub)-grandmean).^2;
    
    for sess=1:nsessions
        WMS = WMS + (dat(sub,sess)-subjmean(sub)).^2;
                     
        EMS = EMS + (dat(sub,sess)-subjmean(sub)-sessionmean(sess)+grandmean).^2;
    
        SST = SST +  (dat(sub,sess)-grandmean).^2;                      
    end
end;
  
for sess=1:nsessions
    JMS=  (sessionmean(sess)-grandmean).^2;
end;
  
%define the true value of the mean square.
BMS= nsessions.*BMS./(nsubjects-1);
WMS= WMS./(nsessions-1)./nsubjects;
JMS= nsubjects.*JMS./(nsessions-1);
EMS= EMS./(nsessions-1)./(nsubjects-1); 
  
%(case 1) Shrout & Fleiss psych. bull. 1979, vol 86, No 2, 420.  
ICC=(BMS-WMS)./(BMS+(nsessions-1).*WMS); 
  
%(case 2A -consistency agreement) McGraw & Wong psych. meths. 1996, vol 1, No 1, 30.  
ICC_2A_con=(BMS-EMS)./(BMS+(nsessions-1).*EMS); 
  
%(case 2A -absolute agreement takes ito account session variation) Geon-Ho
% et al Radiology  2005, vol 234, No 3, 909.
ICC_2A=(BMS-EMS)./(BMS+(nsessions-1).*EMS + ...
                                   nsessions.* (JMS-EMS)./nsubjects); 

                               
%pvalues
F_ICC=BMS/WMS;
p_ICC= 1-fcdf(F_ICC,(nsubjects-1),(nsubjects-1)*(nsessions-1));

F_ICC_2A=BMS/EMS;
p_ICC_2A= 1-fcdf(F_ICC_2A,(nsubjects-1),(nsubjects-1)*(nsessions-1));
                               
%coefficient of variation  
cv=sqrt(WMS)./grandmean;

sigmaw=WMS;
sigmae=EMS;

%within subject, absolute agreement
%WS=nsessions.*WMS./(BMS+(nsessions-1).*WMS); 
  
%reproducibility
%WSC = nsessions.* (JMS-EMS)./nsubjects./(BMS+(nsessions-1).*EMS + ...
%                                   nsessions.* (JMS-EMS)./nsubjects); 
                                            
%within subject consistency agreement                                 
%WSC_con= nsessions.* (JMS-EMS)./nsubjects./(nsessions.*EMS + ...
%                                   nsessions.* (JMS-EMS)./nsubjects);                                 
  
%noise                             
%N =   nsessions.*EMS./(BMS+(nsessions-1).*EMS + ...
%                                   nsessions.* (JMS-EMS)./nsubjects);                            
  
%contribution of noise to wms
%N_con = nsessions.*EMS./(nsessions.*EMS + ...
%                                   nsessions.* (JMS-EMS)./nsubjects); 
 
%test correct split of sums of squares: 
%test=test + ...
%sum(sum(abs( ...
%(BMS-EMS)+nsessions.* (JMS-EMS)./nsubjects+nsessions.*EMS - ...
%(BMS+(nsessions-1).*EMS +  nsessions.* (JMS-EMS)./nsubjects)   )));
 
  

fprintf('\n')
fprintf('*******************************\n')
fprintf('Reliability measures for summary statistics \n')
fprintf('type in variables for results \n')
fprintf('\n')
return;

