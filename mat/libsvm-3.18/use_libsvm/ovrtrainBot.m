function [model] = ovrtrainBot(y, x, cmd)
% This function builds K svm models, each responsible for class k versus the
% rest. 

% INPUT: 
% x: an N x D data/feature matrix where N denotes the number of observations and
% D denotes feature dimensionality
% y: an N x 1 label vector, where each element y(n) in the nth row denotes
% the label of the observation x(n,:)
% cmd: the argument to control svm package

% Remarks: 
% 1) The code uses all the observations given in x for training
% 2) The label y is multiclass label, i.e. # of class can be greater than 2

labelSet = unique(y);
% Note: the labels in y are not necessarily in the non-skippy order, for
% instance, the labels can be {-1 3 10}.
labelSetSize = length(labelSet);
models = cell(labelSetSize,1);

for i=1:labelSetSize
    models{i} = svmtrain(double(y == labelSet(i)), x, cmd);
end

model = struct('models', {models}, 'labelSet', labelSet);
% Note: 
% 1) the model models{i} is corresponding to the label labelSet(i)
% 2) When wanting to access the ith train model, use model.models{i}
% 3) to access the label use model.labelSet, and for the ith label, use
% model.labelSet(i)