function [predictedLabel, decisValueWinner, totalAccuracy, confusionMatrix, order] = classifyUsingCrossValidation(label, data, run, Ncv_classif, option)
% The function performs classification using n-fold cross validation
% according to the "run" vector denoted by run.
% let the number of observations is denoted by N, and the number of
% features is denoted by D
%
% INPUT:
% label: A N x 1 vector denoting the ground-truth labels for each observation
% data: A N x D data/feature matrix corresponding to label
% run: An N x 1 vector specifying which observation is in which of the n
% folds. It is important that each element in vector run must be in the range of [1 to Ncv_classif]. 
% Ncv_classif: A scalar representing the number of cross validation
% option: options for svm
%
% OUTPUT:
% predictedLabel: An Nx1 vector denoting the predicted label for each
% observation
% decisValueWinner: An Nx1 vector denoting the decision value of each
% observation w.r.t. its assigned class label
% totalAccuracy: A scalar representing the verall classification accuracy
% confusionMatrix: A NClass x NClass confusion matrix
% order: An NClass x 1 vector representing the order of the class labels in
% the confusion matrix confusionMatrix
%
% Kittipat "Bot" Kampa
% kittipat@gmail.com
% Integrated Brain Imaging Center, UW Medical Center, Seattle, UW
% Last modified: May 14, 2012
%
% See also automaticParameterSelection.m

if exist('option','var')
    c = option.c;
    g = option.gamma;
    NClass = option.NClass;
    svmCmd = option.svmCmd;
end

% Prepare/initialize some matrices to store some information
confusionMatrix = zeros(NClass,NClass,Ncv_classif);
order = zeros(NClass,Ncv_classif);
totalAccuracy = zeros(1,Ncv_classif);
predictedLabel = label*0;
decisValueWinner = label*0;

% SVM parameters
% the best parameters are obtained from some cross validation process
cmd = ['-c ',num2str(c),' -g ',num2str(g),' ',svmCmd];

for ncv = 1:Ncv_classif
    
    % Pick one fold at a time
    testIndex = run == ncv;
    trainIndex = run ~= ncv;
    trainData = data(trainIndex,:);
    trainLabel = label(trainIndex,:);
    testData = data(testIndex,:);
    testLabel = label(testIndex,:);
    NTest = sum(testIndex,1);
    
    % #######################
    % Train the SVM in one-vs-rest (OVR) mode
    % #######################
    model = ovrtrainBot(trainLabel, trainData, cmd);
    
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