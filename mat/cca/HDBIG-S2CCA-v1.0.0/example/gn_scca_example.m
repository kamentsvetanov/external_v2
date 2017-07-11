clc;clear all;
% -----------------------------------------
% Run this example to see how to use
%------------------------------------------
% Author: Lei Du, leidu@iu.edu
% Date created: Feb-10-2014
% Update: Aug-07-2015
% Copyright (C) 2013-2015 Li Shen (shenli@iu.edu) and Lei Du
% -----------------------------------------

% set path
cd ../.;
root = cd;
addpath(genpath([root '/']));

% change to the original folder
cd example;

% load data sets
load example_data2.mat;

% set parameters, should be tuned before running.
% As an example, we fix them.
paras.alpha1 = 0.1;
paras.alpha2 = 0.1;
paras.lambda1 = 1;
paras.lambda2 = 1;
paras.beta1 = 10;
paras.beta2 = 10;

% run group sparse CCA method
X = getNormalization(X);
Y = getNormalization(Y);
[u, v, pcorr] = gn_scca(X, Y, paras);
save res_gn-scca_example.mat;

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