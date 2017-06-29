
basedir = ('/Users/tor/Dropbox/Kansas_Workshop_Aug2012/Data_Wager_NSF_Pain')

database = fullfile(basedir, 'Sample_data_NSF_study');

%d = filenames(fullfile(datadir, '*.mat'), 'char', 'absolute'); n = size(d, 1)

cd(basedir)


%% RELOAD and add mvmt, nuisance
clear all
datadir = ('/Users/tor/Dropbox/Working_items/Pain_Prediction_NSF_DPSP/Revision1_NEJM/Study1_Replicate_original_analysis/data');

basedir = ('/Users/tor/Dropbox/Kansas_Workshop_Aug2012/Data_Wager_NSF_Pain');
cd(basedir)

writedir = fullfile(basedir, 'nuisance');
mkdir(writedir)

% this one has excluded trials removed
%load('/Users/tor/Dropbox/Working_items/Pain_Prediction_NSF_DPSP/Revision1_NEJM/Study1_movement_analysis/analysis_vars.mat', 'mvmt');

% this one has all
load('/Users/tor/Dropbox/Working_items/Pain_Prediction_NSF_DPSP/Revision1_NEJM/Study1_movement_analysis/for_tor_prediction_mvmt_etc.mat', 'mvmt');

load EXPT
%d = EXPT.FILES.datfiles; % in order

for i = 1:length(EXPT.subjects)
    clear dat nuisance
    
%     load(deblank(d(i, :)))
%     dat = replace_empty(dat);
%     
%    [~, tmp] = fileparts(dat.fullpath(1, :));
%    tmp = fullfile(basedir, [EXPT.subjects{i} '_nuisance.mat'];

    tmp = [EXPT.subjects{i} '_nuisance.mat'];
    infofile = fullfile(writedir, tmp);

    disp(EXPT.subjects{i})
    
    % Movement, concatenated
    % -------------------------------------------------
    nuisance.mvmt = mvmt{i};
    nuisance.mvmt_descrip = 'Movement params, concatenated,RPY (radians) then XYZ (mm)';
    
    mplus = zscore(mvmt{i});
    mpd = [0 0 0 0 0 0; diff(mplus)];
    
    nuisance.mvmtplus = [mplus mplus.^2 mpd mpd.^2];
    nuisance.mvmtplus_descrip = 'Movement params (zscored) concat, squares, succ.diffs, sq succ diffs';

    % movement by separate session
    % -------------------------------------------------
    dat.images_per_session = repmat(184, 1, 6); % avoid excluded...
    en = cumsum(dat.images_per_session);
    st = [1 en(1:end-1)+1];
    
    clear sessm sessmplus
    
    for j = 1:length(dat.images_per_session)
        sessm{j} = zscore(mvmt{i}(st(j):en(j), :));
        
        smpd = [0 0 0 0 0 0; diff(sessm{j})];
         
        sessmplus{j} = [sessm{j} sessm{j}.^2 smpd smpd.^2];
    end
    
    nuisance.sessmvmt = blkdiag(sessm{:});
    nuisance.sessmvmtplus = blkdiag(sessmplus{:});
    
    nuisance.sessmvmt_descrip = 'Movement params (zscored), sep sessions';
    nuisance.sessmvmtplus_descrip = 'Movement params plus (zscored), sep sessions';

    % session intercepts
    % -------------------------------------------------
    intc = intercept_model(dat.images_per_session, 1:2);
    
    nuisance.intercept = intc(:, 1:length(dat.images_per_session));
    nuisance.intercept_descrip = 'Intercepts for each run';
    
    nuisance.firsttwo = intc(:, length(dat.images_per_session)+1:end);
    nuisance.firsttwo_descrip = 'Dummy regressors for first two images, each run';
    
    R = [nuisance.sessmvmtplus nuisance.firsttwo nuisance.intercept];
    
    if exist(infofile, 'file')
        save(infofile, '-append', 'nuisance', 'R')
    else
        save(infofile, 'nuisance', 'R')
    end
    
end


%% RELOAD and save trial info

clear all
datadir = ('/Users/tor/Dropbox/Working_items/Pain_Prediction_NSF_DPSP/Revision1_NEJM/Study1_Replicate_original_analysis/data');

basedir = ('/Users/tor/Dropbox/Kansas_Workshop_Aug2012/Data_Wager_NSF_Pain');
cd(basedir)

writedir = fullfile(basedir, 'trialinfo');
mkdir(writedir)

load EXPT
d = EXPT.FILES.datfiles;

for i = 1:length(EXPT.subjects)
    clear dat trialinfo
    disp(EXPT.subjects{i})

    % Load fmri_data mat file 
    load(deblank(d(i, :)))

%     [~, tmp] = fileparts(dat.fullpath(1, :));
%     tmp = [tmp(1:10) '_trialinfo.mat'];
%     
    tmp = [EXPT.subjects{i} '_trialinfo.mat'];
    infofile = fullfile(writedir, tmp);
    
    trialinfo = dat.additional_info; % save for later
    
    % Do not adjust for missing trials - use all!
    TR = 2;
    trialindx = dat.additional_info{6};
    %trialindx(trialindx == 0) = [];
    trialstart = (find(trialindx == 1) - 1) .* TR; % in seconds
    trialinfo{2}(:, 1) = trialstart; % anticipation
    trialinfo{2}(:, 2) = trialstart + 8; % anticipation

    disp(['Saving: ' infofile])
    
    if exist(infofile, 'file')
        save(infofile, '-append', 'trialinfo')
    else
        save(infofile, 'trialinfo')
    end
    
end

%% Get image names

clear all

basedir = ('/Users/tor/Dropbox/Kansas_Workshop_Aug2012/Data_Wager_NSF_Pain/');
cd(basedir)

imagebase = fullfile(basedir, 'Sample_data_NSF_study', 'SubjectData');

wcard1 = fullfile('Functional','canlab_denoised_orig','ra*denoised.img');

wcard2 = fullfile('Functional','canlab_denoised_orig','wra*denoised.img');

load EXPT

% EXPT.FILES = rmfield(EXPT.FILES, 'ra_files');
% EXPT.FILES = rmfield(EXPT.FILES, 'wra_files');
% EXPT.FILES = rmfield(EXPT.FILES, 'im_files');
% EXPT.FILES = rmfield(EXPT.FILES, 'wfiles_3d');
% EXPT.FILES = rmfield(EXPT.FILES, 'wfiles');
% EXPT.FILES = rmfield(EXPT.FILES, 'denoised_files');

for i = 1:length(EXPT.subjects)

    %EXPT.FILES.ra_files{i} = filenames(fullfile(imagebase, EXPT.subjects{i}, wcard1), 'char', 'absolute');

    EXPT.FILES.wra_files{i} = filenames(fullfile(imagebase, EXPT.subjects{i}, wcard2), 'char', 'absolute');

    %EXPT.FILES.wra_bmrk{i} = filenames(fullfile(basedir, 'processed_data', ['wra' EXPT.subjects{i} '*allsessions.img']), 'char', 'absolute');
end

save EXPT EXPT


