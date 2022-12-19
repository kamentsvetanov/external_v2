clc;clear;close all
%+++ Import data
%load corn_m51
%load P
%+++ Choose the number of latent variables
data=xlsread('E:\博士课题实验\预实验\光谱与浓度值.xlsx');
X=data(:,105:450);
y=data(:,514);
MCCV=plsmccv(X,y,15,'none',500,0.8);

%+++ Using CARS to perform variable selection
% CARS=carspls(X,y,MCCV.optPC,5,'center',50); 
% plotcars(CARS);
% SelectedVariables=CARS.vsel


%+++ Also the Simplified version of CARS could also be used. This programe
%+++ scarspls.m can reproduce the variable selection results 
sCARS=scarspls(X,y,MCCV.optPC,10,'none',500); 
plotcars(sCARS);
SelectedVariables=sCARS.vsel




