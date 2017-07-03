function [BPM] = wfu_bpm_reslice_newflists(BPM)
%----- Checking the size of the datasets and reslicing if needed --%

% ------ Reading a data set from the main modality ---------%
file_names = wfu_bpm_read_flist(BPM.flist);
master_fname_old = BPM.flist ;
[sub_file_names{1},no_groups] = wfu_bpm_get_file_names(file_names(1,:));

%----- Obtaining the dimensions of the main modality -----%
Vmm = spm_vol(deblank(sub_file_names{1}{1}(1,:)));

% ---- Reslicing if needed the data of each of the imaging modalities --- %

%----- Create the main file list -------------%

wdir = BPM.result_dir;
name_mainflist =  sprintf('/rmaster_flist.txt');
name_mainflist= strcat(wdir,name_mainflist);
fd_main = fopen(name_mainflist,'w');
fprintf(fd_main,'%d\n',size(file_names,1)); % The first entry (number)
fprintf(fd_main,'%s\n',file_names(1,:)); % The same entry as in the original master file
flag_mf = 0;
for k = 2:(size(file_names,1))  
    
    %------- Obtaining the dimension of the k-th imaging modality ------- %
    [sub_file_names{k},no_groups] = wfu_bpm_get_file_names( file_names(k,:) );
    Vic = spm_vol(deblank(sub_file_names{k}{1}(1,:)));
    
    %------ Comparing with the dimensions of the main modality ---------- %
    if ~isequal(Vmm.dim(1:3),Vic.dim(1:3))
        flag_mf = 1;
        flag.mean = 0 ;
        flag.which = 1;
        % ------- Create modality file list ---------------%
        mod_file{k-1} =  sprintf('/rfile_mod%d.txt',k);
        mod_file{k-1} = strcat(wdir,mod_file{k-1});
        fd_mod = fopen(mod_file{k-1},'w') ;
        
        %------- Opening the original k modality file --------%
        fp_or_modf = fopen(file_names(k,:)); 
        %------- Iterating across groups ----------%
        for m = 1:no_groups
            %-------- Reading the original flist name --------%
            flist_name = fgetl(fp_or_modf);
            %---- Creating the new flist name by adding r in front of the name -----%            
            [path,name,ext] = fileparts(flist_name);
            rflist_name = strcat(path,'/r',name,ext);
            
            %----- Creating the array of file names necessary for spm_reslice 
            group_size = size(sub_file_names{k}{m},1);
            C    = cell(1,group_size);
            C{1} = sub_file_names{1}{1}(1,:);
            count = 2;  
            for n = 1:group_size %size(sub_file_names{k}{m},1)
                C{count} =  sub_file_names{k}{m}(n,:);
                count = count + 1;
            end
            P = strvcat(C);            
            %----- Reslicing --------%
            spm_reslice(P,flag);
            % Create the resliced group file list
            %             grpname{m} =  sprintf('/reslice_grp%d.flist',m);
            %             grpname{m} = strcat(wdir,grpname{m});
            fd = fopen(rflist_name,'w');
            %------ Writing the Number of Subjects -------%
            fprintf(fd,'%d\n',size(P,1)-1); 
            %------ Writing the subjects paths and file names -----%
            for no_subjs = 2:size(P,1)
                [pathstr,name,ext,versn] = fileparts( P(no_subjs,:));
                name = strcat('r',name);
                file_subj = fullfile(pathstr,[name ext versn]);
                %----- Fill Group files ------%
                if no_subjs == size(P,1)
                    fprintf(fd,'%s',file_subj);
                else
                    fprintf(fd,'%s\n',file_subj);
                end                
            end
            fclose(fd);            
            
            %------ Writing the Modality file list ------%
            if m == no_groups
                fprintf(fd_mod,'%s',rflist_name);
            else
                fprintf(fd_mod,'%s\n',rflist_name);
            end
        end
        %----- Closing old and new modality files -----%
        fclose(fp_or_modf);        
        fclose(fd_mod);
        
        %------- Write to the master flist -----------%
        if k == (size(file_names,1))
            fprintf(fd_main,'%s',mod_file{k-1});
        else
            fprintf(fd_main,'%s\n',mod_file{k-1});
        end
        BPM.flist = name_mainflist; % Reassign to the resliced flist
        
        
    else
        fprintf(fd_main,'%s\n',file_names(k,:)); % same as in the original master file
    end
end

fclose(fd_main); 
if ~flag_mf
    delete(name_mainflist);
else
    delete(master_fname_old)
end

