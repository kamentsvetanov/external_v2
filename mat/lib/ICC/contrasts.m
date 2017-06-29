function con_files=contrasts(SPM_file,contr)
%defines the contrast for SPM
%____________________________________________________________________________

if nargin<1
    [SPM_file,sts] =spm_select(1,'mat','select SPM.mat file...');   
end

if nargin<2
   ncon = spm_input('how many contrasts?',1,'e',0,NaN);
   for cons=1:ncon
       contr(cons).name=spm_input('name',2,'s','',NaN);
       contr(cons).vect=spm_input('full contrast',3,'e',[],NaN);;
   end; 
end

%loop over contrasts
for n=1:length(contr)

    contrastname=contr(n).name;
    c=contr(n).vect'    
    load(SPM_file)   
    SPM.xX.xKXs
    xX.xKXs=SPM.xX.xKXs
    DxCon = spm_FcUtil('Set',contrastname,'T','c',c,xX.xKXs);
    SPM.xCon = [SPM.xCon, DxCon];        
    Ic=length(SPM.xCon);     %select last contrast to avaluate
    SPM = spm_contrasts(SPM,Ic);  %produce contrast images
  
    save SPM SPM
    
end;

%define con_files
files = spm_select('List',pwd,'^con.*\.img$');  
nscans=size(files);
nscans=nscans(1);
con_files='';

for sc=1:nscans;
    [sd f ex]=fileparts(files(sc,:));    
    con_files=strvcat(con_files,[pwd '/' f '.img']);
end;

return