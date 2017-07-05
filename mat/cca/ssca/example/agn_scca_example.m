clc;clear all;
% -----------------------------------------
% Run this example to see how to use
%------------------------------------------
% Author: Lei Du, leidu@iu.edu
% Date created: Feb-10-2014
% Update: Aug-07-2015
% @Indiana University School of Medicine.
% -----------------------------------------

% set path
addpath '../data/';
addpath '../data_preprocessing/';
addpath '../scca_code/';

% load data sets
load example_data2.mat;

% set parameters, should be tuned before running.
% As an example, we fix them.
paras.alpha1 = 0.1;
paras.alpha2 = 0.1;
paras.lambda1 = 1;
paras.lambda2 = 1;
paras.beta1 = 1;
paras.beta2 = 1;

% run group sparse CCA method
X = getNormalization(X);
Y = getNormalization(Y);
[u, v, ecorr] = agn_scca(X, Y, paras);
save res_agn-scca_example.mat;

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