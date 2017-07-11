clc;clear;
% -----------------------------------------
% Run this to generate the final results
%------------------------------------------
% Author: Lei Du, leidu@iu.edu
% Date created: Feb-10-2014
% Update: Aug-07-2015
% Copyright (C) 2013-2015 Li Shen (shenli@iu.edu) and Lei Du
% -----------------------------------------

clc; clear;

% set path
cd ../.;
root = cd;
addpath(genpath([root '/']));

% change to the original folder
cd example;

% load data sets
load example_data1.mat;

% set group informations
group_info.X_group = X_group;
group_info.Y_group = Y_group;

% set range of parameters
paras.r1 = 1;
paras.r2 = 1;
paras.beta1 = 10;
paras.beta2 = 10;

% run group sparse CCA method
X = getNormalization(X);
Y = getNormalization(Y);
[u, v, pcorr] = s2cca(X, Y, group_info, paras);
save res_s2cca_example.mat;

% display results
subplot(221);
stem(u0);
title('Ground truth: u');
subplot(222);
stem(v0);
title('Ground truth: v');
subplot(223);
stem(u);
title('Estimated: u');
subplot(224);
stem(v);
title('Estimated: v');

% 
disp('Success! See the saved MAT file for details.');