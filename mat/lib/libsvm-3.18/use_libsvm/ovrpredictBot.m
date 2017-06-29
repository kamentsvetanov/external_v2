function [label_out, acc_out, decv_out] = ovrpredictBot(y, x, model)

labelSet = model.labelSet;
labelSetSize = length(labelSet);
models = model.models;
observationSize = size(y, 1);
% decv= zeros(observationSize, labelSetSize);
label_out = zeros(observationSize,labelSetSize);
decv_out = zeros(observationSize,labelSetSize);
acc_out = zeros(3,labelSetSize);

for i=1:labelSetSize
  [label_out(:,i),acc_out(:,i),decv_out(:,i)] = svmpredict(double(y == labelSet(i)), x, models{i});
  % Here we have to do some strange thing...
  % IF models{i}.Label(1) == 1, the decv_out is stored as it is
  % But if models{i}.Label(1) == 0, the decv_out is multiplied by -1 before
  % stored.
  % After doing this process the decision values are correct!!!
  decv_out(:,i) = decv_out(:,i) * (2 * models{i}.Label(1) - 1);
end
% [tmp,pred] = max(decv, [], 2);
% pred = labelSet(pred);
% ac = sum(y==pred) / size(x, 1);
