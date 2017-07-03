% Classification type: multiclass, one-vs-rest (OVR)
% Parameter selection: multi-scale automatic but not perfect
% Classification: leave-one-out n-fold cross validation on a single data set
% Kernel: default (not specified)
% Data set: 10-class spiral

% data: N x D matrix, each row represent feature vector of an observation
% run: N x 1 matrix containing the run#
% label: N x 1 matrix containing the label for each observation

clear
close all
clc

%% Generate a data set containing run information
% % % dirData = './data';
% % % Nc = 10;
% % % Ns = 100;
% % % h = 15;
% % % r = 3;
% % % [data, label, run] = generateSpiralDataWithLabels(Nc,Ns,h,r);
% % % save(fullfile(dirData,'spiral_Nc10_cv'),'data','label','run');

%% 
% Load data
% rearrange the data for n-fold cross validation

% Load the data
dirData = './data';
load(fullfile(dirData,'spiral_Nc10_cv'));
data = data(:,1:2);

% rearranging the data
labelList = unique(label);
NClass = length(labelList);
[Ns D] = size(data);
% Here we will make them into 5 folds
Ncv = 5;
runNew = mod(run,Ncv)+1;

% plot the figure before rearranging
figure;
subplot(1,4,2); imagesc(runNew); title('modulo of the run#'); colorbar;
subplot(1,4,1); imagesc(run); title('original run number'); colorbar;
subplot(1,4,3); imagesc(label); title('label'); colorbar;
subplot(1,4,4); imagesc(data); title('feature'); colorbar;

% sort everything according to the run
[runSorted, permMatrix] = sortrows(runNew);
labelSorted = label(permMatrix);
dataSorted = data(permMatrix,:);

figure;
subplot(1,3,1); imagesc(runSorted); title('sorted run #'); colorbar;
subplot(1,3,2); imagesc(labelSorted); title('sorted label'); colorbar;
subplot(1,3,3); imagesc(dataSorted); title('sorted data'); colorbar;


%%

% Prepare/initialize some matrices to store some information
confusionMatrix = zeros(NClass,NClass,Ncv);
order = zeros(NClass,Ncv);
totalAccuracy = zeros(1,Ncv);
predictedLabel = labelSorted*0;
decisValueWinner = labelSorted*0;

% SVM parameters
% the best parameters are obtained from some cross validation process
bestParam = ['-q -c 64 -g 0.015625'];

for ncv = 1:Ncv
    
    % Pick one fold at a time
    testIndex = runSorted == ncv;
    trainIndex = runSorted ~= ncv;
    trainData = dataSorted(trainIndex,:);
    trainLabel = labelSorted(trainIndex,:);
    testData = dataSorted(testIndex,:);
    testLabel = labelSorted(testIndex,:);
    NTest = sum(testIndex,1);
    
    % #######################
    % Train the SVM in one-vs-rest (OVR) mode
    % #######################
    model = ovrtrainBot(trainLabel, trainData, bestParam);
    
    % #######################
    % Classify samples using OVR model
    % #######################
    [predict_label, accuracy, decis_values] = ovrpredictBot(testLabel, testData, model);
    [decis_value_winner, label_out] = max(decis_values,[],2);
    predictedLabel(testIndex) = label_out;
    decisValueWinner(testIndex) = decis_value_winner;
    % #######################
    % Make confusion matrix
    % #######################
    [confusionMatrix(:,:,ncv),order(:,ncv)] = confusionmat(testLabel,label_out);
    totalAccuracy(ncv) = trace(confusionMatrix(:,:,ncv))/NTest;
    disp(['Fold ', num2str(ncv),' -- Total accuracy from the SVM: ',num2str(totalAccuracy(ncv)*100),'%']);
    % Note: For confusionMatrix
    % column: predicted class label
    % row: ground-truth class label
    % But we need the conventional confusion matrix which has
    % column: actual
    % row: predicted
    
% % %     % Plot the confusion matrix for each fold
% % %     figure; imagesc(confusionMatrix(:,:,ncv)');
% % %     xlabel('actual class label');
% % %     ylabel('predicted class label');
% % %     title(['confusion matrix for fold ',num2str(ncv)]);
    

end

% #######################
% Make confusion matrix for the overall classification
% #######################
[confusionMatrixAll,orderAll] = confusionmat(labelSorted,predictedLabel);
figure; imagesc(confusionMatrixAll');
xlabel('actual class label');
ylabel('predicted class label');
title(['confusion matrix for overall classification']);
% Calculate the overall accuracy from the overall predicted class label
accuracyAll = trace(confusionMatrixAll)/Ns;
disp(['Total accuracy from ',num2str(Ncv),'-fold cross validation is ',num2str(accuracyAll*100),'%']);

% % % % Average the accuracy from each fold accuracy
% % % % This is supposed to give the same thing as the method above
% % % avgAccuracy = mean(totalAccuracy(:),1);
% % % disp(['average accuracy is ',num2str(avgAccuracy*100),'%']);

% Compare the actual and predicted class
figure;
subplot(1,2,1); imagesc(labelSorted); title('actual class');
subplot(1,2,2); imagesc(predictedLabel); title('predicted class');

% ################################
% Plot the clustering results
% ################################
% plot the true label for the test set
patchSize = 20*exp(decisValueWinner);
colorList = generateColorList(NClass);
colorPlot = colorList(labelSorted,:);
figure; 
scatter(dataSorted(:,1),dataSorted(:,2),patchSize, colorPlot,'filled'); hold on;

% plot the predicted labels for the test set
patchSize = 10*exp(decisValueWinner);
colorPlot = colorList(predictedLabel,:);
scatter(dataSorted(:,1),dataSorted(:,2),patchSize, colorPlot,'filled');