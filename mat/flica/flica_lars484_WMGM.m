%% flica_lars484struct: A test script.
% Validate against:
% load ~/flicaValidationIn.mat; vb2_test_multimodal4

addpath([getenv('FSLDIR') '/etc/matlab/'])

%% Set the output directory:
outdir = ['~/scratch/lars484WMGM_' datestr(now, 'YYYY-mm-DD_HH-MM-SS') '/']
mkdir(outdir); % Error if fails. Warning if already exists (user should stop if they don't want to overwrite previous results!)


%% Load Y from data files
srcDir = '/vols/Scratch/adriang/data/oslo/lars484/';
Yfiles = {
            [srcDir 'all_FA_skeletonised_2mm.nii.gz']
            [srcDir 'all_MD_skeletonised_2mm.nii.gz']
            [srcDir 'all_MO_skeletonised_2mm.nii.gz']
            [srcDir 'orig/?h.thick.fsaverage5.10.mgh']
            [srcDir 'orig/?h.pial.area.fsaverage5.10.mgh'],
            [srcDir 'GM_mod_merg_s2_4mm.nii.gz']
            %[srcDir 'GM_mod_merg_s3_4mm.nii.gz']
            %[srcDir 'GM_mod_merg_s4_4mm.nii.gz']
            %[srcDir 'GM_mod_merg_s0_masked.nii.gz']
            %[srcDir 'GM_mod_merg_s2_masked.nii.gz']
                };
%transformsIn = {'','','',''; 'log','','',''; '','','',''};  % Log-transform area; everything else uses defaults.
transformsIn = {'','','',''; 'log','','',''; '','','','';'','','',''; 'log','','',''; '','','',''};  % Log-transform MD and area. 
[Y,fileinfo] = flica_load(Yfiles, transformsIn);
fileinfo.shortNames = {'FA','MD','MO','Thickness','Area','VBM'};
%fileinfo.shortNames = {'Thickness','Area','VBM'};


%% Set non-default options
% To see a list of options: run flica_parseoptions, with no arguments.
opts = struct();
opts.num_components = 100;
opts.maxits = 3000;
%opts.keyboardEveryIterations = 0; % 0 = don't stop
%opts.Rgroups = [ones(242,1);2*ones(242,1)]; warning 'Rgroups 1 2!'
%Y = Y(1); warning 'Single modality!!'; 
%opts.lambda_dims = 'G'; warning 'Groupwise noise!'
%opts.Rgroups = mod(1:484,2)'+1; warning 'Rgroups 1 2!'
% if 1
%     designOrig = load('~/scratch/data/oslo/lars484/design.txt');
%     %female = logical(designOrig(:,1));
%     %opts.Rgroups = 1+female;
%     %age = designOrig(:,2);
%     %opts.Rgroups = 1 + (age>60);
%     swver = designOrig(:,12);
%     opts.Rgroups = swver/2 - 5.5;
%     clear designOrig female age swver
% end

opts.calcFits = 'all'; % Be more careful, check F increases every iteration.

%% Run FLICA
Morig = flica(Y, opts);
%[M,weights] = flica_reorder(Morig); % Sort components sensibly

Hpaper3 = read_vest('~adriang/www/paper3/subjectCoursesOut.txt')';
[M,weights] = flica_reorder(Morig, Hpaper3); % Sort components sensibly

%% Create the output directory and save everything!



%[retval,outdir] = dos('mktemp -d /tmp/flicaTEST.XXXX'); 
%assert(retval==0); assert(outdir(end)==10); outdir(end) = '/';
flica_save_everything(outdir, M, fileinfo);

%% Produce report analyses

    %% Load subject variables for this data set (vb2_test_surfaces:94-197)
    % required variables: outdir.
    designOrig = load('~/scratch/data/oslo/lars484/design.txt');
    clear des
    age = designOrig(:,2);
    des.Age = age;
    
    female = logical(designOrig(:,1));
    des.Sex.values = double(female);
    des.Sex.dithered = double(female) -0.2 + 0.4*rand(size(female));
    des.Sex.style = '.'; %{{'b*'},{'.', 'color',[0 0.5 0]}};
    des.Sex.groups = double(female)+1;
    des.Sex.limits = [-.5,1.5];
    des.Sex.xtick = [0 1];
    des.Sex.xticklabel = {'Male','Female'};
        
    des.ICV.values = designOrig(:,10)/1e6;
    des.ICV.groups = double(female)+1;
    
    des.Sex_orth_ICV.values = orthwrt(female, [ones(size(female)) designOrig(:,10)]) + mean(female);
    des.Sex.groups = double(female)+1;
    des.Sex_orth_ICV.xtick = [0 1];
    des.Sex_orth_ICV.xticklabel = {'Male','Female'};
    des.Sex_orth_ICV.groups = double(female)+1;
    
    des.ScanDate = (datenum(num2str(designOrig(:,11)),'yyyymmdd')) / datenum('2006-01-01')*2006;
    
    %des.ScanDate_orth_Age_Age2_Gender = ...
    %    orthwrt(des.ScanDate, [ones(size(female)) female age age.^2]);
    
    SWver = designOrig(:,12);
    des.SWver.values = SWver;
    des.SWver.dithered = SWver-0.4+0.8*rand(size(SWver));
    des.SWver.style = 'b.';
    des.SWver.limits = [12 18];
    des.SWver.xtick = [13 15 17];
    
    des.SWver_orth_Age_Age2_Gender = ...
        orthwrt(des.SWver.values, [ones(size(female)) female age age.^2]);


    % Correlate H with subject variables & do statistics
    % Produce nice plots of this too, and save them
    flica_posthoc_correlations(outdir, des)
    
    disp 'Done producing correlations!'
    
%% OPTIONALLY Upsample to produce prettier report:
    %% Find filenames of highres versions
    YfilesHR = Yfiles;
    YfilesHR = regexprep(YfilesHR, '_2mm', '');
    YfilesHR = regexprep(YfilesHR, '.fsaverage5.10.', '.fsaverage.10.');
    YfilesHR = regexprep(YfilesHR, '_s2_4mm', '_s4_masked');
    %% Load highres data and applycorrString{i,1} = ['<b>' corrString{i,1} '**</b>']; the same transformations to it
    % Check for a decent match between high-res and low-res files
    % Re-fit the X matrices using the new Y and existing W, H, lambda, pi, beta, mu.
        % For each k: {Xq, q, X moments} or {X,beta} (for VBFPT)
    % Save results again?
    % If MD is included: multiply transforms{2,3} by 500, for lars484 files.
    %outdirHR = [outdir '/HR/']; - no, use HR auto
    flica_upsample(outdir, YfilesHR, fileinfo.transforms, Y)

    % Call surface & stuff with a suffix and flag.  WILL overwrite other
    % rendered images!
        
%% Produce report images (do entirely in scripts??)
    %% Use tksurfer to render volumes: On system with freesurfer rendering working!
    % CALL: render_surfaces.sh, in the output directory, from a system with freesurfer installed.
    % OR: render_surfaces.sh _HR -- to use upsampled images!
    %% Call surf2vol to generate volumes for surface files: on Jal00!c
    % CALL: surfaces_to_volumes.sh *mriOut_mi?_l.mgh *mriOut_mi?_r.mgh *niftiOut_mi?.nii.gz fsaverage5 /usr/local/fsl/data/standard/MNI152_T1_2mm.nii.gz
    % i.e. surfaces_to_volumes_all.sh fsaverage5
    % $FSLDIR/data/standard/MNI152_T1_1mm.nii.gz _HR
    % OR: surfaces_to_volumes.sh *mriOut_mi?_l_HR.mgh *mriOut_mi?_r_HR.mgh *niftiOut_mi?_HR.nii.gz fsaverage /usr/local/fsl/data/standard/MNI152_T1_1mm.nii.gz
    %% Call render_lightbox.sh on all volume files
    % CALL: render_lightboxes.sh niftiOut_mi?.nii.gz _mi?
    % OR: render_lightboxes.sh niftiOut_mi?_HR.nii.gz _mi?  (not _HR? overwrite?)
    
%% Produce the actual report webpage(s)
% CALL: flica_report.sh 









