% Move contrasts to analyze and manage them

% load subject etc details

disp('Congratuations! Ready to perform group analysis!');
org_pwd=pwd;

%2nd level-analisis dir
group_dir = fullfile(PAR.root,PAR.groupdir);
if ~exist(group_dir)
    mdir=['mkdir(PAR.root,PAR.groupdir)'];
    eval(mdir);
end
for i=1:length(PAR.con_names)
    conf_dir=fullfile(PAR.root,PAR.groupdir,PAR.con_names{i});
    if ~exist(conf_dir)
%         mdir=['!mkdir ' conf_dir];
        mdir=['mkdir(group_dir, PAR.con_names{i})'];
        eval(mdir);
    else
        cd(conf_dir);
        delete con*
    end

    %copy contrasts
    for sub=1:PAR.nsubs
        ana_dir = fullfile(PAR.root,PAR.subjects{sub},PAR.ana_dir);
        source_file=spm_select('FPList',ana_dir,['^con_00\w*\.nii$']);
        
        dest_file=spm_file(source_file,'path', conf_dir, 'prefix', [PAR.subjects{sub}]);
        if isunix
            cpf=['!cp -f ' source_file ' ' dest_file ];
            eval(cpf);
            
        else
            copyfile([source_file], [dest_file],'f');
        end
    end
end  %end for each contrast

cd(org_pwd);