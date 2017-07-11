% example of Knowledge Guided Sparse Canonical Correlation Analysis (KG_SCCA)

%% 
clear all
clc

%% read data from xlsx files
cd('../00_data')
X_file = {'./association_data.xlsx','X'};
Y_file = {'./association_data.xlsx','Y'};
X_group_file = {'./association_data.xlsx','group_X'};
Y_network_file = {'./association_data.xlsx','network_Y'};

X = xlsread(X_file{1},X_file{2});
Y = xlsread(Y_file{1}, Y_file{2});
group = xlsread(X_group_file{1}, X_group_file{2});
network = xlsread(Y_network_file{1}, Y_network_file{2});

%% for those snps does not belong to any group
%  assign an extra group

max_g = max(group);
i_zero_g = group==0;
zero_gNum = sum(i_zero_g);
group(i_zero_g) = max_g+1:max_g+zero_gNum;

%% data preprocessing
% remove subjects with empty or NaN entries
cd('../02_data_preprocessing')
[X, Y] = datacheck(X, Y);
% normalize the data
x_normalize = normalization(X);
y_normalize = normalization(Y);

%% main regression function
% Set parameters
para.beta1 = 10;
para.beta2  = 10;
para.theta1 = 10;
para.theta2 = 10;
cd('../03_association_code');
[u,v,obj] = A_KG_SCCA(x_normalize,y_normalize, group, network, para);

%%
comp_X = x_normalize * u;
comp_Y = y_normalize * v;
CC = comp_X' * comp_Y;

%%
clearvars -except u v obj CC comp_X comp_Y
cd('../01_example');

