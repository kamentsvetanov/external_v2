% Batch mode scripts for running spm5 in TRC
% Created by Ze Wang, 08-05-2004
% zewang@mail.med.upenn.edu


fprintf('\r%s\n',repmat(sprintf('-'),1,30))
fprintf('%-40s\n','Set PAR')


clear
global PAR
PAR=[];


PAR.SPM_path=spm('Dir');
addpath(PAR.SPM_path);

% This file sets up various things specific to this
% analysis, and stores them in the global variable PAR,
% which is used by the other batch files.
% You don't have to do it this way of course, I just
% found it easier



%%%%%%%%%%%%%%%%%%%%%
%                   %
%   GENERAL PREFS   %
%                   %
%%%%%%%%%%%%%%%%%%%%%%
% Where the subjects' data directories are stored

PAR.batchcode_which= mfilename('fullpath');
PAR.batchcode_which=fileparts(PAR.batchcode_which);
addpath(PAR.batchcode_which);
old_pwd=pwd;
cd(PAR.batchcode_which);
cd ../
data_root=pwd;
cd(old_pwd);


PAR.root=data_root;

% Subjects' directories
PAR.subjects = {'sub1' 'sub2' 'sub3' } ;
PAR.nsubs = length(PAR.subjects);



% Anatomical directory name
PAR.structfilter='Anatomy';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the anatomical image directories automatically
for sb=1:PAR.nsubs
    tmp=dir(fullfile(PAR.root,PAR.subjects{sb},['*' PAR.structfilter '*']));
    if size(tmp,1)==0
        sprintf('Can not find the anatomical directory for subject\n')
        sprintf('%s: \n', char(PAR.subjects{sb}))
        error('Can not find the anatomical directory for subject');
    end
    if size(tmp,1)>1
        sprintf('More than 1 anatomical directories for subject: %s are found here!\n',char(PAR.subjects{sb}))
        error('More than 1 anatomical directories are found')
    end
    PAR.structdir{sb}=fullfile(PAR.root,PAR.subjects{sb},spm_str_manip(char(tmp(1).name),'d'));
end
%prefixes for filenames of structural 3D images, supposed to be the same for every subj.
PAR.structprefs = 'Anatomy';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Getting condition directories
PAR.confilters={'PASL_S1'}; %filter for folder name and filenames of functional images
PAR.ncond=length(PAR.confilters);
PAR.M0filters = {'PASL_S1M0'};

% The condition names are assumed same for different sessions

for sb=1:PAR.nsubs
    for c=1:PAR.ncond
        tmp=dir(fullfile(PAR.root,PAR.subjects{sb},['*' PAR.confilters{c} ]));

        if size(tmp,1)==0
            sprintf('Can not find the condition directory for subject\n')
            sprintf('%s: \n', char(PAR.subjects{sb}))
            error('Can not find the condition directory for subject');
        end

        if size(tmp,1)>1
            sprintf('Panic! subject %s has more than 1 directories!\n', [PAR.subjects{sb}])
            error('Panic! condition has more than 1 directories!')
            %return;
        end
        PAR.condirs{sb,c}=fullfile(PAR.root,PAR.subjects{sb},spm_str_manip(char(tmp(1).name),'d'));
        
        
          tmp=dir(fullfile(PAR.root,PAR.subjects{sb},['*' PAR.M0filters{c} ]));
             if size(tmp,1)==0
            sprintf('Can not find the M0 directory for subject\n')
            sprintf('%s: \n', char(PAR.subjects{sb}))
            error('Can not find the M0 directory for subject');
        end

        if size(tmp,1)>1
            sprintf('Panic! subject %s has more than 1 M0 directories!\n', [PAR.subjects{sb}])
            error('Panic! condition has more than 1 M0 directories!')
            %return;
        end
        
          PAR.M0dirs{sb,c}=fullfile(PAR.root,PAR.subjects{sb},spm_str_manip(char(tmp(1).name),'d'));
          
    end
end

% Smoothing kernel size
PAR.FWHM = [6];

% % TR for each subject.  As one experiment was carried out in one Hospital (with one machine)
% % and the other in another hospital (different machine), TRs are slightly different
% %PAR.TRs = [2.4696 2];
PAR.TRs = ones(1,PAR.nsubs)*6;
% PAR.mp='no';

% % Model stuff
% % Condition namesfiles
PAR.cond_names = {'rest','tap'};
PAR.condnum=length(PAR.cond_names);
PAR.Onsets={[0 24 48]
    [12 36 60]};

PAR.Durations={[12]
    [12]};

%
PAR.mp='no';
%
PAR.groupdir = ['group_anasmallPerf_sinc'];

%contrast names
PAR.con_names={'tap_rest'};


PAR.subtractiontype=0;
PAR.glcbffile=['globalsg_' num2str(PAR.subtractiontype) '.txt'];
PAR.img4analysis='cbf'; % or 'Perf'
PAR.ana_dir = ['glm_' PAR.img4analysis];
PAR.Filter='cbf_0_sr';



