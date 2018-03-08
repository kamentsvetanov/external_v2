% n-fold cross validation on matrix 
% data: N x D matrix, each row represent feature vector of an observation
% run: N x 1 matrix containing the run#
% label: N x 1 matrix containing the label for each observation
% 
% clear
% close all
% clc
% 
% %% 
% % Load data
% % rearrange the data for n-fold cross validation
% 
% % Load the data
% dirData = './data';
% load(fullfile(dirData,'spiral_Nc10_cv'));
% data = data(:,1:2);


data  = X.data;
label = X.group;
label(label==-1)=2;
% Extract important information
labelList = unique(label);
NClass = length(labelList);
[Ns D] = size(data);

% Make the run index for each observation
% Here we will make them into 5 folds
Ncv_classif = 5;
runCVIndex = mod(run,Ncv_classif)+1;

%%
% #######################
% Parameter selection
% #######################
% First we randomly pick some observations from the training set for parameter selection
tmp = randperm(size(data,1));
evalIndex = tmp(1:ceil(size(data,1)/2));
evalData = data(evalIndex,:);
evalLabel = label(evalIndex,:);

% #######################
% Automatic Cross Validation 
% Parameter selection using n-fold cross validation
% #######################
% ================================================================
% Note that the cross validation for parameter selection can use different
% number of fold. In tis example
% Ncv_param = 3 but 
% Ncv_classif = 5;
% Also note that we don't have to specify the fold for cv for parameter
% selection as the algorithm will pick observations into each fold
% randomly.
% ================================================================
optionCV.stepSize = 5;
optionCV.c = 1;
optionCV.gamma = 1/D;
optionCV.stepSize = 5;
optionCV.bestLog2c = 0;
optionCV.bestLog2g = log2(1/D);
optionCV.epsilon = 0.005;
optionCV.Nlimit = 100;
optionCV.svmCmd = '-q';
Ncv_param = 3; % Ncv-fold cross validation cross validation
[bestc, bestg, bestcv] = automaticParameterSelection(evalLabel, evalData, Ncv_param, optionCV);


%%

% #######################
% Classification using N-fold cross validation
% #######################
optionClassif.c = bestc;
optionClassif.gamma = bestg;
optionClassif.NClass = NClass;
optionClassif.svmCmd = '-q';
[predictedLabel, decisValueWinner, totalAccuracy, confusionMatrix, order] = classifyUsingCrossValidation(label, data, runCVIndex, Ncv_classif, optionClassif);

%%
% #######################
% Make confusion matrix for the overall classification
% #######################
[confusionMatrixAll,orderAll] = confusionmat(label,predictedLabel);
figure; imagesc(confusionMatrixAll');
xlabel('actual class label');
ylabel('predicted class label');
title(['confusion matrix for overall classification']);
% Calculate the overall accuracy from the overall predicted class label
accuracyAll = trace(confusionMatrixAll)/Ns;
disp(['Total accuracy from ',num2str(Ncv_classif),'-fold cross validation is ',num2str(accuracyAll*100),'%']);

% Compare the actual and predicted class
figure;
subplot(1,2,1); imagesc(label); title('actual class');
subplot(1,2,2); imagesc(predictedLabel); title('predicted class');

%%
% ################################
% Plot the clustering results in 2D
% ################################
% Pick the 2D representation to plot
if D==2
    data2D = data(:,1:2);
elseif D>2
    % Dimensionality reduction to 2D
    
%     % ******** Using MDS (Take longer time)
%     distanceMatrix = pdist(data,'euclidean');
%     data2D = mdscale(distanceMatrix,2);
    
    % ******** Using classical MDS (Pretty short time)
    distanceMatrix = pdist(data,'euclidean');
    data2D = cmdscale(distanceMatrix); data2D = data2D(:,1:2);
end
% plot the true label for the test set
tmp = min(exp(zscore(decisValueWinner)),10);
tmp = tmp-min(tmp(:))+1;
tmp = tmp/max(tmp);

patchSize = 200*tmp;
colorList = generateColorList(NClass);
colorPlot = colorList(label,:);
figure; 
scatter(data2D(:,1),data2D(:,2),patchSize, colorPlot,'filled'); hold on;

% plot the predicted labels for the test set
patchSize = patchSize/2;
colorPlot = colorList(predictedLabel,:);
scatter(data2D(:,1),data2D(:,2),patchSize, colorPlot,'filled');