% Classification type: multiclass, one-vs-rest (OVR)
% Parameter selection: multi-scale automatic, quite perfect
% Classification: on the separated test set
% Kernel: either default or specified are fine
% Data set: 10-class spiral

% The code is developed based on _test7. The improvement is that the
% automatic cross validation for parameter selection is made into a
% function, which is much more convenient. The function is  
% 
% automaticParameterSelection.m

clear
clc
close all

% addpath to the libsvm toolbox
addpath('../libsvm-3.12/matlab');

%% read the data set Spiral
dirData = './data';

load(fullfile(dirData,'spiral_Nc10_train'));
rawTrainData = data(:,1:2);
rawTrainLabel = label;
NTrain = size(rawTrainData,1);
[sortedTrainLabel, permIndex] = sortrows(rawTrainLabel);
sortedTrainData = rawTrainData(permIndex,:);

load(fullfile(dirData,'spiral_Nc10_test'));
rawTestData = data(:,1:2);
rawTestLabel = label;
NTest = size(rawTestData,1);
[sortedTestLabel, permIndex] = sortrows(rawTestLabel);
sortedTestData = rawTestData(permIndex,:);

% combine the data together just to fit my format
totalData = [sortedTrainData; sortedTestData];
totalLabel = [sortedTrainLabel; sortedTestLabel];
figure; 
subplot(1,2,1); imagesc(totalLabel); title('class label');
subplot(1,2,2); imagesc(totalData); title('features');

[N D] = size(totalData);
labelList = unique(totalLabel(:));
NClass = length(labelList);

% #######################
% Determine the train and test index
% #######################
trainIndex = zeros(N,1); trainIndex(1:NTrain) = 1;
testIndex = zeros(N,1); testIndex( (NTrain+1):N) = 1;
trainData = totalData(trainIndex==1,:);
trainLabel = totalLabel(trainIndex==1,:);
testData = totalData(testIndex==1,:);
testLabel = totalLabel(testIndex==1,:);

%%
% #######################
% Automatic Cross Validation 
% Parameter selection using n-fold cross validation
% #######################
optionCV.stepSize = 5;
optionCV.c = 1;
optionCV.gamma = 1/D;
optionCV.stepSize = 5;
optionCV.bestLog2c = 0;
optionCV.bestLog2g = log2(1/D);
optionCV.epsilon = 0.005;
optionCV.Nlimit = 100;
optionCV.svmCmd = '-q';
Ncv = 3; % Ncv-fold cross validation cross validation
[bestc, bestg, bestcv] = automaticParameterSelection(trainLabel, trainData, Ncv, optionCV);

%%
% #######################
% Train the SVM in one-vs-rest (OVR) mode
% #######################
% % % % With specific kernel
% % % bestParam = ['-q -c ', num2str(bestc), ', -g ', num2str(bestg),' -t 2'];
% % % model = ovrtrainBot(trainLabel, [(1:NTrain)' trainData*trainData'], bestParam);
% Without specific kernel
bestParam = ['-q -c ', num2str(bestc), ', -g ', num2str(bestg)];
model = ovrtrainBot(trainLabel, trainData, bestParam);
% bestParam = ['-q -c 8 -g 0.0625'];
% #######################
% Classify samples using OVR model
% #######################
% % With specific kernel
% [predict_label, accuracy, decis_values] = ovrpredictBot(testLabel, [(1:NTest)' testData*trainData'], model);
% With specific kernel
[predict_label, accuracy, decis_values] = ovrpredictBot(testLabel, testData, model);
[decis_value_winner, label_out] = max(decis_values,[],2);

% #######################
% Make confusion matrix
% #######################
[confusionMatrix,order] = confusionmat(testLabel,label_out);
% Note: For confusionMatrix
% column: predicted class label
% row: ground-truth class label
% But we need the conventional confusion matrix which has
% column: actual
% row: predicted
figure; imagesc(confusionMatrix');
xlabel('actual class label');
ylabel('predicted class label');
totalAccuracy = trace(confusionMatrix)/NTest;
disp(['Total accuracy from the SVM: ',num2str(totalAccuracy*100),'%']);
%%
% #######################
% Plot the results
% #######################
figure; 
subplot(1,3,2); imagesc(predict_label); title('predicted labels'); xlabel('class k vs rest'); ylabel('observations'); colorbar;
subplot(1,3,1); imagesc(decis_values); title('decision values'); xlabel('class k vs rest'); ylabel('observations'); colorbar;
subplot(1,3,3); imagesc(label_out); title('output labels'); xlabel('class k vs rest'); ylabel('observations'); colorbar;

% plot the true label for the test set
tmp = min(exp(zscore(decis_value_winner)),10);
tmp = tmp-min(tmp(:))+1;
tmp = tmp/max(tmp);

patchSize = 50*tmp;
colorList = generateColorList(NClass);
colorPlot = colorList(testLabel,:);
figure; 
scatter(testData(:,1),testData(:,2),patchSize, colorPlot,'filled'); hold on;

% plot the predicted labels for the test set
patchSize = patchSize/2;
colorPlot = colorList(label_out,:);
scatter(testData(:,1),testData(:,2),patchSize, colorPlot,'filled');

%%
% #######################
% Plot the decision boundary
% #######################

% Generate data to cover the domain
minData = min(totalData,[],1);
maxData = max(totalData,[],1);
stepSizePlot = (maxData-minData)/50;
[xI yI] = meshgrid(minData(1):stepSizePlot(1):maxData(1),minData(2):stepSizePlot(2):maxData(2));
% #######################
% Classify samples using OVR model
% #######################
fakeData = [xI(:) yI(:)];
% % % % With specific kernel
% % % [pdl, acc, dcsv] = ovrpredictBot(xI(:)*0,[(1:size(fakeData))' fakeData*trainData'], model);
% Without specific kernel
[pdl, acc, dcsv] = ovrpredictBot(xI(:)*0,fakeData, model);
% Note: when the ground-truth labels of testData are unknown, simply put
% any random number to the testLabel
[dcsv_winner, label_domain] = max(dcsv,[],2);

% plot the result
tmp = min(exp(zscore(dcsv_winner)),10);
tmp = tmp-min(tmp(:))+1;
tmp = tmp/max(tmp);

patchSize = 50*tmp;
colorList = generateColorList(NClass);
colorPlot = colorList(label_domain,:);
figure; 
scatter(xI(:),yI(:),patchSize, colorPlot,'filled');