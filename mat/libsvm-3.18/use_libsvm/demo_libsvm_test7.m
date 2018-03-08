% Classification type: multiclass, one-vs-rest (OVR)
% Parameter selection: multi-scale automatic, quite perfect
% Classification: on the separated test set
% Kernel: either default or specified are fine
% Data set: 10-class spiral

clear
clc
close all

% addpath to the libsvm toolbox
addpath('../libsvm-3.12/matlab');

%%
% % % % make a dataset
% % % dirData = './data';
% % % Nc = 4;
% % % Ns = 50;
% % % h = 15;
% % % r = 3;
% % % [data, label, run] = generateSpiralDataWithLabels(Nc,Ns,h,r);
% % % save(fullfile(dirData,'spiral_Nc4_test'),'data','label','run');


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
stepSize = 5;
bestLog2c = 0;
bestLog2g = log2(1/D);
epsilon = 0.005;
bestcv = 0;
Ncv = 3; % Ncv-fold cross validation cross validation
deltacv = 10^6;
Nlimit = 10;
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
    cvMatrix = zeros(numLog2c,numLog2g);
    
    for i = 1:numLog2c
        log2c = log2c_list(i);
        for j = 1:numLog2g
            log2g = log2g_list(j);
            % With some kernel
            cmd = ['-q -c ', num2str(2^log2c), ' -g ', num2str(2^log2g),' -t 0'];
            cv = get_cv_ac(trainLabel, [(1:NTrain)' trainData*trainData'], cmd, Ncv);
% % %             % With some precal kernel
% % %             cmd = ['-q -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
% % %             cv = get_cv_ac(trainLabel, trainData, cmd, Ncv);
            if (cv >= bestcv),
                bestcv = cv; bestLog2c = log2c; bestLog2g = log2g;
                bestc = 2^bestLog2c; bestg = 2^bestLog2g;
            end
            disp(['So far, cnt=',num2str(cnt),' the best parameters, yielding Accuracy=',num2str(bestcv*100),'%, are: C=',num2str(bestc),', gamma=',num2str(bestg)]);
            % Break out of the loop when the cnt is up to the condition
            if cnt > Nlimit, breakLoop = 1; break; end
            cnt = cnt + 1;
        end
        if breakLoop == 1, break; end
    end
    if breakLoop == 1, break; end
    deltacv = bestcv - bestcv_prev;
    
end
disp(['The best parameters, yielding Accuracy=',num2str(bestcv*100),'%, are: C=',num2str(bestc),', gamma=',num2str(bestg)]);
%%
% % % % #######################
% % % % Semi-manual cross validation
% % % % Parameter selection using n-fold cross validation
% % % % #######################
% % % % === traditional manual cv =====
% % % bestcv = 0;
% % % for log2c = -1:1:5,
% % %   for log2g = -8:1:3,
% % %     cmd = ['-q -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
% % %     cv = get_cv_ac(trainLabel, trainData, cmd, 3);
% % %     if (cv >= bestcv),
% % %       bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
% % %     end
% % %     %fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
% % %   end
% % % end
% % % disp(['The best parameters, yielding Accuracy=',num2str(bestcv*100),'%, are: C=',num2str(bestc),', gamma=',num2str(bestg)]);
% % % % ===============================



%%
% #######################
% Train the SVM in one-vs-rest (OVR) mode
% #######################
% With specific kernel
bestParam = ['-q -c ', num2str(bestc), ', -g ', num2str(bestg),' -t 0'];
model = ovrtrainBot(trainLabel, [(1:NTrain)' trainData*trainData'], bestParam);
% % % % Without specific kernel
% % % bestParam = ['-q -c ', num2str(bestc), ', -g ', num2str(bestg)];
% % % model = ovrtrainBot(trainLabel, trainData, bestParam);
% bestParam = ['-q -c 8 -g 0.0625'];
% #######################
% Classify samples using OVR model
% #######################
% With specific kernel
[predict_label, accuracy, decis_values] = ovrpredictBot(testLabel, [(1:NTest)' testData*trainData'], model);
[decis_value_winner, label_out] = max(decis_values,[],2);
%
% % % % With default kernel
% % % [predict_label, accuracy, decis_values] = ovrpredictBot(testLabel, testData, model);
% % % [decis_value_winner, label_out] = max(decis_values,[],2);

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