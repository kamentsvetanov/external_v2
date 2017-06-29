function [label_out, acc_out, decv_out] = ovrpredictBot(y, x, model)

labelSet = model.labelSet;
labelSetSize = length(labelSet);
models = model.models;
observationSize = size(y, 1);
% decv= zeros(observationSize, labelSetSize);
label_out = zeros(observationSize,labelSetSize);
decv_out = zeros(observationSize,labelSetSize);
acc_out = zeros(1,labelSetSize);

for i=1:labelSetSize
  [label_out(:,i),acc_out(1,i),decv_out(:,i)] = svmpredict(double(y == labelSet(i)), x, models{i});
%   decv(:, i) = decv_out * (2 * models{i}.Label(1) - 1);
end
% [tmp,pred] = max(decv, [], 2);
% pred = labelSet(pred);
% ac = sum(y==pred) / size(x, 1);
