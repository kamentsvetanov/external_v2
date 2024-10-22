function [y] = ica_fuse_convertToZScores(y)
% function to convert to z scores 
% observations must be in rows (rows correspond to number of observations
% and columns correspond to values)

ica_fuse_defaults;

% detrend number
global DETREND_NUMBER;


if isempty(DETREND_NUMBER)
    detrendNumber = 0;
else
    detrendNumber = DETREND_NUMBER;
end

% number of cols
[num_rows, num_cols] = size(y);

% loop over number of observations
for ii = 1:num_rows
    % get the current observation
    currentObservation = y(ii, :);
    % remove the trend
    [currentObservation] = ica_fuse_detrend(currentObservation, 1, length(currentObservation), detrendNumber);
    if size(currentObservation, 1) ~= 1
        currentObservation = currentObservation';
    end
    % z-score value
    y(ii, :) = currentObservation./std(currentObservation);
    clear currentObservation;
end
