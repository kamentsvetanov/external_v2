clear all

basedir = ('/Users/tor/Dropbox/Kansas_Workshop_Aug2012/Data_Wager_NSF_Pain');
cd(basedir)
load EXPT

% Select which subjects to run here
% ----------------------------------------
subjs = 1:length(EXPT.subjects);

% Model name
modelname = 'model3';

% Select which components to run here, 1/0
% ----------------------------------------
set_up_onsets = 0;                      % First level
build_spm_batch_job = 0;                % <-----------------------------
specify_and_estimate = 0;
spec_est_only_if_missing = 1;           % run the spec/est only if files are missing
specify_and_estimate_contrasts = 0;
review_designs = 1;

robust_regression_setup = 0;            % Second level
robust_regression_run = 0;              % <-----------------------------
robust_regression_results = 0;


% Results saved in diary file
% ----------------------------------------
diaryname = fullfile(basedir, 'first_level', modelname, 'model_work_log.txt');


% Make sure a few other things are in place before running
% ----------------------------------------
if ~exist(fullfile(basedir, 'first_level'), 'dir')
    mkdir(fullfile(basedir, 'first_level'));
end

if ~exist(fullfile(basedir, 'second_level'), 'dir')
    mkdir(fullfile(basedir, 'second_level'));
end

if ~exist(fullfile(basedir, 'first_level', modelname), 'dir')
    mkdir(fullfile(basedir, 'first_level', modelname));
end

if ~exist(fullfile(basedir, 'second_level', modelname), 'dir')
    mkdir(fullfile(basedir, 'second_level', modelname));
end

%% % RELOAD and construct MODEL 
% SET UP ONSETS, ETC
if set_up_onsets
    
    %     clear all
    
    %         basedir = ('/Users/tor/Dropbox/Kansas_Workshop_Aug2012/Data_Wager_NSF_Pain');
    cd(basedir)
    
    datadir = fullfile(basedir, 'trialinfo');
    
    load EXPT
    
    for i = subjs
        clear trialinfo nuisance
        
        disp(EXPT.subjects{i})
        
        infofile = fullfile(datadir, [EXPT.subjects{i} '_trialinfo.mat']);
        if isempty(infofile)
            disp('Cannot find info file')
        end
        load(infofile)
        
        disp(['Loading: ' infofile])
        
        
        % Info common to models
        % -------------------------------------------------
        
        anticons = trialinfo{2}(:, 1); % onset times for events from start of session, in sec
        painons = trialinfo{2}(:, 2); % onset times for events from start of session, in sec
        
        temp = trialinfo{2}(:, 4) - 32; % temperature, diff from baseline, C
        pain = trialinfo{2}(:, 5);      % pain post-trial
        
        prevtemp = [mean(temp); temp(1:end-1)]; % previous trial temperature
        
        u = unique(temp);
        for j = 1:length(u)
            painindic{j} = painons(temp == u(j));
        end
         
        modeldir = fullfile(basedir, 'first_level', modelname, EXPT.subjects{i});
        if ~exist(modeldir, 'dir'), mkdir(modeldir); end
        
        modelfile = fullfile(modeldir, [modelname '_setup.mat']);
                
        % Model 1: All onsets, temp is PM
        % *** EDIT HERE TO CHANGE MODEL ***
        % -------------------------------------------------

        names = {'Antic' 'Pain'};
        onsets{1} = anticons;
        onsets{2} = painons;
        durations{1} = 2;
        durations{2} = 10;
        pmod{1} = [];
        pmod{2} = struct('name',{'Pain_mod_temp','Pain_mod_prev_temp'},'param',{temp, prevtemp},'poly',{1,1});
        
        
        % *** END EDITS ***
        % -------------------------------------------------
        
        disp(['Saving: ' modelfile])
        
        if exist(modelfile, 'file')
            save(modelfile, '-append', 'names', 'onsets', 'pmod', 'durations')
        else
            save(modelfile, 'trialinfo', 'names', 'onsets', 'pmod', 'durations')
        end
    end
    
end

%% RELOAD and build matlab batch file
% Save SPM batch file
if build_spm_batch_job
    
    %     clear all
    %
    %     basedir = ('/Users/tor/Dropbox/Kansas_Workshop_Aug2012/Data_Wager_NSF_Pain');
    cd(basedir)
    
    TR = 2;
    HP = 180;
    
    datadir = fullfile(basedir, 'processed_data');
    nuisancedir = fullfile(basedir, 'nuisance');
    
    %     load EXPT
    
    for i = subjs
        
        disp(EXPT.subjects{i})
        
        % Image data
        % *** EDIT here to change where filenames are saved/which files are used
        imgfile = check_valid_imagename(EXPT.FILES.wra_files{i}); % denoised canlab
        %imgfile = check_valid_imagename(EXPT.FILES.wra_bmrk{i});    % biomarker preproc
        
        % Nuisance regressors
        % *** EDIT here to change where filename for nuisance regressors are saved/which files are used
        nuisancefile = fullfile(nuisancedir, [EXPT.subjects{i} '_nuisance.mat']);
        if isempty(nuisancefile)
            disp('Cannot find info file')
        end
      
        disp(['Using: ' nuisancefile])
        
        % Output dir
        modeldir = fullfile(basedir, 'first_level', modelname, EXPT.subjects{i});
        if ~exist(modeldir, 'dir'), mkdir(modeldir); end
        
        % Model onsets and info
        clear names onsets durations pmod
        modelfile = fullfile(modeldir, [modelname '_setup.mat']);
        load(modelfile)
        
        % Create batch file
        matlabbatch = canlab_spm_fmri_model_job(modeldir, TR, HP, ...
            {imgfile}, length(onsets), onsets, durations, names, ...
            {nuisancefile}, 'pmod', pmod, 'is4d');
        
        % Save
        batchfile = fullfile(modeldir, 'spm_model_spec_estimate_job.mat');
        save(batchfile, 'matlabbatch');
    end
    
end

%% RELOAD and run SPM batch files to estimate models

if specify_and_estimate
    
    % clear all
    
    cd(basedir)
    
    for i = subjs
        
        modeldir = fullfile(basedir, 'first_level', modelname, EXPT.subjects{i});
        if ~exist(modeldir, 'dir'), mkdir(modeldir); end
        
        if spec_est_only_if_missing
            
            if exist(fullfile(modeldir, 'beta_0001.img'), 'file')
                v = spm_read_vols(spm_vol(fullfile(modeldir, 'beta_0001.img')));
                v = v(:);
                if any(abs(v) > 100*eps & ~isnan(v))
                    %skip model for this subject - we have already
                    diary(diaryname), fprintf('%s spec/estimation skipped: already exists.\n', EXPT.subjects{i}), diary off
                    continue
                end
            end
            
        end
        
        batchfile = fullfile(modeldir, 'spm_model_spec_estimate_job.mat');
        load(batchfile, 'matlabbatch');
        
        % - Run the job
        try
            spm('Defaults', 'fMRI') % <- get current defaults; otherwise will not reload from .m            
            spm_jobman('run', matlabbatch);
            diary(diaryname), fprintf('%s spec/estimation success.\n', EXPT.subjects{i}), diary off
            
            % - After running, check the design using:
            scn_spm_design_check(modeldir, 'events_only');
            
        catch
            diary(diaryname), fprintf('%s spec/estimation FAILED.\n', EXPT.subjects{i}), diary off
        end
        
        
    end
    
end

%% CONTRASTS FOR ALL SUBJECTS
% ------------------------------------------------------------------------

% *** EDIT CONTRASTS FOR NEW MODEL ***
% % ------------------------------------------------------------------------

input_contrasts = {};
input_contrasts{1} = {  {'PainxPain_mod_temp^1*bf(1)'}  };
input_contrasts{2} = {  {'PainxPain_mod_prev_temp^1*bf(1)'}  };
input_contrasts{3} = {  {'Pain*bf(1)'}  };
input_contrasts{4} = {  {'Painxtime^1*bf(1)'}  };
input_contrasts{5} = {  {'Antic*bf(1)'}  };
input_contrasts{6} = {  {'Anticxtime^1*bf(1)'}  };

% *** END EDITS ***
% ------------------------------------------------------------------------

if specify_and_estimate_contrasts
    
  
    for i = subjs
        
        modeldir = fullfile(basedir, 'first_level', modelname, EXPT.subjects{i});
        
        try
            [matlabbatch, connames, contrast_vectors] = canlab_spm_contrast_job(modeldir, input_contrasts, 'exact'); %, 'nosave', 'norun');
            diary(diaryname), fprintf('%s contrast success.\n', EXPT.subjects{i}), diary off
            
        catch
            diary(diaryname), fprintf('%s contrast FAILURE.\n', EXPT.subjects{i}), diary off
            
        end
        
    end
    
end

%% Design review

if review_designs
    publish_model(modelname, 1, 0);
end


%% Robust regression Setup
% ------------------------------------------------------------------------

if robust_regression_setup
    
    EXPTm = [];
    EXPTm.subjects = EXPT.subjects;
    EXPTm.SNPM.connames = [];
    EXPTm.SNPM.P = {};
    
    modeldir = fullfile(basedir, 'first_level', modelname);
    cd(modeldir)
    
    for i = 1:length(input_contrasts)
        imgs = filenames(fullfile(modeldir, '*', sprintf('con_%04d.img', i)), 'char', 'absolute');
        
        EXPTm.SNPM.P(i) = {imgs};
        EXPTm.SNPM.connums(i, 1) = i;
        
        nm = input_contrasts{i}{1}{1};
        wh = find(nm == '*');
        nm = nm(1:wh-1);
        
        EXPTm.SNPM.connames = char(EXPTm.SNPM.connames, nm);
        
    end
    
    EXPTm.SNPM.connames = EXPTm.SNPM.connames(2:end, :);
    
    modeldir = fullfile(basedir, 'second_level', modelname);
    mkdir(modeldir)
    cd(modeldir);
    
    save EXPTm EXPTm
    
end


%% Robust regression - Run and get results batch
% ------------------------------------------------------------------------

if robust_regression_run
    
    modeldir = fullfile(basedir, 'second_level', modelname);
    mkdir(modeldir)
    cd(modeldir);
    
    load EXPTm EXPTm
    
    try
        EXPTm = robfit(EXPTm, 1:length(EXPTm.SNPM.connums), 0, which('brainmask.nii'));
        
        diary(diaryname), fprintf('Robust regressions run successfully.\n'), diary off
    catch
        diary(diaryname), fprintf('Robust regressions failed.\n'), diary off
    end
    
end


%%
if robust_regression_results

    publish_model(modelname, 0, 1);
    
end % if

%%

% canlab_create_wm_ventricle_masks(wm_mask, gm_mask)

% [nuisance, nuisance_comps] = canlab_extract_ventricle_wm_timeseries(mask_image_dir)

%
