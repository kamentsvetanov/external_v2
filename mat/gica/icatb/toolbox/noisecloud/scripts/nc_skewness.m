function s = nc_skewness(data)
%% Compute skewness of the data
%
% Inputs:
% 1. data - Input data
%
% Outputs:
% 1. s - Skewness
%

data = detrend(data, 0);
num = mean(data.^3);
denom = (mean(data.^2)).^1.5;
s = num ./ denom;
