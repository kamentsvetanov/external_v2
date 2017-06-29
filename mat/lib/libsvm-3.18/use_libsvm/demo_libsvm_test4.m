% Classification type: multiclass, one-vs-rest (OVR)
% Parameter selection: semi-automatic, just pick a range of parameter (c,g)
% Classification: on the separated test set
% Kernel: default (not specified)
% Data set: dna_scale

clear
clc
close all

% addpath to the libsvm toolbox
addpath('../libsvm-3.12/matlab');

% addpath to the data
dirData = './data';
addpath(dirData);


% read the data set
[dnaTrainLabel, dnaTrainData] = libsvmread(fullfile(dirData,'dna.scale'));
NTrain = size(dnaTrainData,1);
[dnaTrainLabel, permIndex] = sortrows(dnaTrainLabel);
dnaTrainData = dnaTrainData(permIndex,:);
[dnaTestLabel, dnaTestData] = libsvmread(fullfile(dirData,'dna.scale.t'));
NTest = size(dnaTestData,1);
[dnaTestLabel, permIndex] = sortrows(dnaTestLabel);
dnaTestData = dnaTestData(permIndex,:);

% combine the data together just to fit my format
totalData = [dnaTrainData; dnaTestData];
totalLabel = [dnaTrainLabel; dnaTestLabel];
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

% #######################
% Parameter selection using 3-fold cross validation
% #######################
bestcv = 0;
for log2c = -1:1:3,
  for log2g = -4:1:2,
    cmd = ['-q -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
    cv = get_cv_ac(trainLabel, trainData, cmd, 3);
    if (cv >= bestcv),
      bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
    end
    fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
  end
end

% #######################
% Train the SVM in one-vs-rest (OVR) mode
% #######################
bestParam = ['-q -c ', num2str(bestc), ' -g ', num2str(bestg)];
model = ovrtrain(trainLabel, trainData, bestParam);
% #######################
% Classify samples using OVR model
% #######################
[predict_label, accuracy, prob_values] = ovrpredict(testLabel, testData, model);
fprintf('Accuracy = %g%%\n', accuracy * 100);


% ================================
% ===== Showing the results ======
% ================================

% Assign color for each class
colorList = generateColorList(NClass); % This is my own way to assign the color...don't worry about it
% colorList = prism(100);

% true (ground truth) class
trueClassIndex = zeros(N,1);
for i = 1:NClass
    trueClassIndex(totalLabel==labelList(i)) = i;
end
colorTrueClass = colorList(trueClassIndex,:);
% result Class
resultClassIndex = zeros(length(predict_label),1);
for i = 1:NClass
    resultClassIndex(predict_label==labelList(i)) = i;
end
colorResultClass = colorList(resultClassIndex,:);

% Reduce the dimension from 13D to 2D
distanceMatrix = pdist(totalData,'euclidean');
% newCoor = mdscale(distanceMatrix,2); % take loger time, but more beautiful
newCoor = cmdscale(distanceMatrix); % take loger time, but more beautiful
% Plot the whole data set
x = newCoor(:,1);
y = newCoor(:,2);
patchSize = 30; %max(prob_values,[],2);
colorTrueClassPlot = colorTrueClass;
figure; scatter(x,y,patchSize,colorTrueClassPlot,'filled');
title('whole data set');

% Plot the test data
x = newCoor(testIndex==1,1);
y = newCoor(testIndex==1,2);
patchSize = 30;% 80*max(prob_values,[],2);
colorTrueClassPlot = colorTrueClass(testIndex==1,:);
figure; hold on;
scatter(x,y,2*patchSize,colorTrueClassPlot,'o','filled');
scatter(x,y,patchSize,colorResultClass,'o','filled');
% Plot the training set
x = newCoor(trainIndex==1,1);
y = newCoor(trainIndex==1,2);
patchSize = 30;
colorTrueClassPlot = colorTrueClass(trainIndex==1,:);
scatter(x,y,patchSize,colorTrueClassPlot,'o');
title('classification results');



