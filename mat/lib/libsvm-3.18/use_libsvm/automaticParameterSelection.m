function [bestc, bestg, bestcv] = automaticParameterSelection(trainLabel, trainData, Ncv, option)
% This function assist you to obtain the parameters C (c) and gamma (g)
% automatically.
%
% INPUT:
% trainLabel: An Nx1 vector denoting the label for each observation
% trainData: An N x D matrix denoting the feature/data matrix
% Ncv: A scalar representing Ncv-fold cross validation for parameter
% selection. Note that this function does not require the user to specify
% the run number for each iteration because it automatically assigns the run
% number in the code "get_cv_ac.m" (from the svmlib).
% option: options for parameters selecting
%
% OUTPUT:
% bestc: A scalar denoting the best value for C
% bestg: A scalar denoting the best value for g
% bestcv: the best accuracy calculated from the train data set
%
% Kittipat "Bot" Kampa
% kittipat@gmail.com
% Integrated Brain Imaging Center, UW Medical Center, Seattle, UW
% Last modified: May 14, 2012
%
% See also classifyUsingCrossValidation.m

% #######################
% Automatic Cross Validation 
% Parameter selection using n-fold cross validation
% #######################
[N, D] = size(trainData);

if nargin>3
    stepSize = option.stepSize;
    bestLog2c = log2(option.c);
    bestLog2g = log2(option.gamma);
    epsilon = option.epsilon;
    Nlimit = option.Nlimit;
    svmCmd = option.svmCmd;
else
    stepSize = 5;
    bestLog2c = 0;
    bestLog2g = log2(1/D);
    epsilon = 0.005;
    Ncv = 3; % Ncv-fold cross validation cross validation
    Nlimit = 100;
    svmCmd = '';
end

% initial some auxiliary variables
bestcv = 0;
deltacv = 10^6;
cnt = 1;
breakLoop = 0;

while abs(deltacv) > epsilon && cnt < Nlimit
    bestcv_prev = bestcv;
    prevStepSize = stepSize;
    stepSize = prevStepSize/2;
    log2c_list = bestLog2c-prevStepSize: stepSize: bestLog2c+prevStepSize;
    log2g_list = bestLog2g-prevStepSize: stepSize: bestLog2g+prevStepSize;
    
    numLog2c = length(log2c_list);
    numLog2g = length(log2g_list);
    
    for i = 1:numLog2c
        log2c = log2c_list(i);
        for j = 1:numLog2g
            log2g = log2g_list(j);
% % %             % With some kernel
% % %             cmd = ['-q -c ', num2str(2^log2c), ' -g ', num2str(2^log2g),' -t 2'];
% % %             cv = get_cv_ac(trainLabel, [(1:NTrain)' trainData*trainData'], cmd, Ncv);
            % With some precal kernel
            cmd = ['-c ', num2str(2^log2c), ' -g ', num2str(2^log2g),' ',svmCmd];
            cv = get_cv_ac(trainLabel, trainData, cmd, Ncv);
            if (cv >= bestcv),
                bestcv = cv; bestLog2c = log2c; bestLog2g = log2g;
                bestc = 2^bestLog2c; bestg = 2^bestLog2g;
            end
            disp(['So far, cnt=',num2str(cnt),' the best parameters, yielding Accuracy=',num2str(bestcv*100),'%, are: C=',num2str(bestc),', gamma=',num2str(bestg)]);
            % Break out of the loop when the cnt is up to the condition
            if cnt >= Nlimit, breakLoop = 1; break; end
            cnt = cnt + 1;
        end
        if breakLoop == 1, break; end
    end
    if breakLoop == 1, break; end
    deltacv = bestcv - bestcv_prev;
    
end
disp(['The best parameters, yielding Accuracy=',num2str(bestcv*100),'%, are: C=',num2str(bestc),', gamma=',num2str(bestg)]);
