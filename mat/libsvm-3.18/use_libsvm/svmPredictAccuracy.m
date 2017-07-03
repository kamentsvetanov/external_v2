function acc = svmPredictAccuracy(y_test, X_test, y_train, X_train, svmParam)
% This code will calculate the accuracy of SVM based on
% X: an mxn feature matrix
% y: an mx1 class label vector 

% ================================
% Basic SVM
% ================================
if nargin < 5
svmParam = [' -b 1 -c 10 -g 0.1'];
end
% Train the SVM
model = svmtrain(y_train, X_train, svmParam);
% Use the SVM model to classify the data
[y_predicted, accuracy, decisValueWinner] = svmpredict(y_test, X_test, model, '-b 1'); % run the SVM model on the test data
acc = sum(y_predicted==y_test,1)/length(y_test);