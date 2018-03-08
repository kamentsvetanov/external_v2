function fname = wfu_bpm_write_flist(wdir,flist,Nmodalities)
%__________________________________________________________________________
% This function creates the master and modality files. The master file
% contains the list of the modality files paths and names. The modality
% files contains the lists of paths and names of the flist files
% corresponding to each modality.
%__________________________________________________________________________
% Input parameters
% wdir        - working directory
% flist       - cell containing as many elements as modalities. Each element will
%               be a cell containing as many elements as groups are involved in the
%               current analysis.
% Nmodalities - Number of modalities in the current analysis.
%__________________________________________________________________________
% Output parameters 
% fname      - path and name of the master file.
%__________________________________________________________________________

cd(wdir)
[M,N] = size(flist{1});
fd1 = fopen('master_flist.txt','wt');
fprintf(fd1,'%d\n',Nmodalities);    
for m = 1:Nmodalities
    file_name = sprintf('file_mod%d.txt',m);
    file_name1 = strcat(wdir,'/');
    file_name = strcat(file_name1,file_name);
    fd = fopen(file_name,'w');
    for k = 1:max(M,N)
        if k == max(M,N)
            fprintf(fd,'%s',flist{m}{k});
        else
            fprintf(fd,'%s\n',flist{m}{k});
        end
    end
    fclose(fd);   
    fprintf(fd1,'%s\n',file_name);    
end
fclose(fd1);
fname = strcat(wdir,'/master_flist.txt');
