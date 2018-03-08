% Note: scripts run in publish have access to variables in the base
% workspace, but not any variables created in a calling function.
% We can use assignin.m to assign relevant variables to base workspace.

z = '________________________________________________________________________________________________________';


%if robust_regression_results

modeldir = fullfile(basedir, 'second_level', modelname);
if ~exist(modeldir, 'dir')
    diary(diaryname), fprintf('Model dir does not exist. Skipping all...\n'); disp(modeldir), diary off
end

cd(modeldir);

load EXPTm EXPTm

for i = 1:length(EXPTm.SNPM.P)
    
    robregdir = fullfile(modeldir, sprintf('robust%04d', i));
    
    if ~exist(robregdir, 'dir')
        diary(diaryname), fprintf('%s robust results: dir does not exist/not run yet (skipping.)\n', EXPTm.SNPM.connames(i, :)), diary off
        continue
    end
    
    cd(robregdir)
    
    fprintf('%s\n%s\n%s\n%s\n%s\n%s\n', z, z, EXPTm.SNPM.connames(i, :), robregdir, z, z);
    
    try
        maskimg = fullfile(pwd, 'rob_tmap_0001.img'); % any image in space with non-zero vals for all vox
        robust_results_batch('thresh', [.001 .005 .05], 'size', [5 1 1], 'prune');
        diary(diaryname), fprintf('%s robust results success.\n', EXPTm.SNPM.connames(i, :)), diary off
        
    catch
        diary(diaryname), fprintf('%s robust results failed.\n', EXPTm.SNPM.connames(i, :)), diary off
        
    end
    
    cd ..
    
end

%end % ifdbstop if error
