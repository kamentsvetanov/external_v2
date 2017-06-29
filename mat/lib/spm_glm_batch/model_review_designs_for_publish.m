% Note: scripts run in publish have access to variables in the base
% workspace, but not any variables created in a calling function.
% We can use assignin.m to assign relevant variables to base workspace.

z = '_________________________________________________';

%% FIRST-LEVEL MODEL DESIGN REVIEW

% Save SPM batch file
%if review_designs

cd(basedir)

for i = subjs
    
    fprintf('%s\n%s\n%s\n', z, EXPT.subjects{i}, z);
    
    modeldir = fullfile(basedir, 'first_level', modelname, EXPT.subjects{i});
    disp(modeldir);
    
    try
        % - After running, check the design using:
        scn_spm_design_check(modeldir, 'events_only');
        snapnow
    catch
        diary(diaryname), fprintf('%s design review FAILED.\n', EXPT.subjects{i}), diary off
    end
    
    
end

%end

% Histograms of contrast maps plotted in publish robust results