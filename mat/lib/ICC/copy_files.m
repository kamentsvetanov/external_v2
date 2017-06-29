%script to copy contrast files to a single directory defined by the user
%-----------------------------------------------------

global defaults
spm_defaults;

%% Set up %%
cwd = pwd;

%select directories
sel1=[''];
    
[root,sts1] = spm_select(Inf,'dir','Select root...',sel1, ...
                         cwd,'.*',[]);

cd(root);
if exist('subdir') == 0
    sel2='';
else
    load subdir
    sel2=[subdir];
end

[sub_dir,sts2] =spm_select(Inf,'dir','Select subject directories...',sel2,...
                           pwd,'.*',[]);

subdir=sub_dir;
save subdir subdir;                         
                         
%set up result directories

res=spm_input('directory name',1,'s','results',NaN);
if exist([root,'/',res])~=7  %check that contrast directories exist
   mkdir([root,'/',res]);        
end;        

%ask for image prefix to set the filter
prefix=spm_input('contrast to copy',2,'s','con_000',NaN);
%prefix = ''; %select every image in the folder!
prefix = ['^' prefix '.*\.img$'];

%% Main Program %%
cd(root);

%number of subjects
nsubs=size(sub_dir);
nsubs=nsubs(1);

%loop on subjects
for sb=1:nsubs
    fprintf('...computing subject')
    fprintf('%5.1f \n', sb)
  
    cd([deblank(sub_dir(sb,:))]); 
    %get images    
    
    files = spm_select('List',[deblank(sub_dir(sb,:))],prefix);
    
    %write full path in filenames
    nscans=size(files);
    nscans=nscans(1);
    Filename='';
     
    for sc=1:nscans;
       Filename=strvcat(Filename,fullfile(pwd,files(sc,:)));
    end;   
          
    if nscans~=1
       fprintf('Error:0 or more than one image selected!')
       return
    end;
    
    %define contrasts
    con_files=Filename;
    
    sub_so_far = spm_select('List',[root,'/',res],'^SUBJ.*\.img$'); 
    nso_far=size(sub_so_far);
    nso_far=nso_far(1);
    
    [ds f ex]=fileparts(con_files);
    s = sprintf('%02.f', 1+nso_far);
    copyfile([ds,'/', f, '.img' ],[root,'/',res, '/SUBJ',s, f, '.img' ])
    copyfile([ds,'/', f, '.hdr' ],[root,'/',res, '/SUBJ',s, f, '.hdr' ] )
       
 
end; 

cd(cwd);
fprintf('......copy done.\n\n')
return;




