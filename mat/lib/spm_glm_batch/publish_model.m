function publish_model(modelname, pub_review_designs, pub_robust_regression_results)
% publish_model(modelname, pub_review_designs [1/0 flag], pub_robust_regression_results [1/0 flag])
%
%publish_model(modelname, 1, 0) % designs only
%publish_model(modelname, 0, 1) % regression results only
% publish_model(modelname, 1, 1) % both



%clear all

basedir = ('/Users/tor/Dropbox/Kansas_Workshop_Aug2012/Data_Wager_NSF_Pain');
cd(basedir)
load EXPT

% Select which subjects to run here
% ----------------------------------------
subjs = 1:length(EXPT.subjects);

% Select which components to run here, 1/0
% ----------------------------------------
if nargin == 1
    pub_review_designs = 1;                      % First level % <-----------------------------
    
                                                 % Second level % <-----------------------------
    pub_robust_regression_results = 1;
end

% Note: scripts run in publish have access to variables in the base
% workspace, but not any variables created in a calling function.
%
% We can use assignin.m to assign relevant variables to base workspace.
assignin('base', 'basedir', basedir)
assignin('base', 'EXPT', EXPT)
assignin('base', 'modelname', modelname)

assignin('base', 'review_designs', pub_review_designs)
assignin('base', 'robust_regression_results', pub_robust_regression_results)

assignin('base', 'subjs', subjs)

% ------------------------------------------------------------------------

if pub_review_designs
    
diaryname = fullfile(basedir, 'first_level', modelname, 'model_review_work_log.txt');
scriptdir = fullfile(basedir, 'scripts');

scriptname = fullfile(scriptdir, ['model_review_designs_for_publish.m']);
addpath(scriptdir)

outputbase = fullfile(basedir, 'first_level', modelname); 
outputdir = fullfile(outputbase, 'Design_review_html');
mkdir(outputdir)

p = struct('useNewFigure', false, 'maxHeight', 1500, 'maxWidth', 1200, ...
    'outputDir', outputdir, 'showCode', false);

assignin('base', 'diaryname', diaryname)
publish(scriptname, p)

end

% ------------------------------------------------------------------------

if pub_robust_regression_results
    
diaryname = fullfile(basedir, 'second_level', modelname, 'results_work_log.txt');
scriptdir = fullfile(basedir, 'scripts');

scriptname = fullfile(scriptdir, ['robust_reg_results_for_publish.m']);
addpath(scriptdir)

outputbase = fullfile(basedir, 'second_level', modelname); 
outputdir = fullfile(outputbase, 'Robust_Regression_Results_html');
mkdir(outputdir)

p = struct('useNewFigure', false, 'maxHeight', 1500, 'maxWidth', 1200, ...
    'outputDir', outputdir, 'showCode', false);

assignin('base', 'diaryname', diaryname)
publish(scriptname, p)

end

end % function


