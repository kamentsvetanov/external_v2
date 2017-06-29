function ICC_one_sample_t()
%runs the spm first level to define the one sample t-test


spm_spm_ui;
    
temp=load('SPM');    
defaults.modality='FMRI';
 
temp_SPM=spm_spm(temp.SPM);
       
contr.name='up';
contr.vect=1;
con_files=contrasts('SPM.mat',contr);

