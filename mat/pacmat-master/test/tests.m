%% Load data
clear
clc
load('C:/gh/bv/pacmat/test/exampledata.mat')
fs = 1000;

%% Test to see if PAC functions return values consistent with python

% Set tolerance level
a_tol = 0.00001;

plvval = pac_plv(data,data,[13,30],[80,200],fs);
assert(abs(plvval - 0.23778) < a_tol)

glmval = pac_glm(data,data,[13,30],[80,200],fs);
assert(abs(glmval - 0.03191) < a_tol)

tmival = pac_tmi(data,data,[13,30],[80,200],fs,20);
assert(abs(tmival - 0.00366) < a_tol)

cmival = pac_cmi(data,data,[13,30],[80,200],fs);
assert(abs(cmival - 1.10063) < a_tol)

ozkurtval = pac_ozkurt(data,data,[13,30],[80,200],fs);
assert(abs(ozkurtval - 0.07548) < a_tol)

otcval = pac_otc(data,[80,200],4,fs,7,95,[-.5,.5],0.01);
assert(abs(otcval - 220.32563) < a_tol)

comod = comodulogram(data, data, [10,21],[50,150], 5, 50, fs, 'mi_tort');
assert(abs(comod(1,1) - 0.00287) < a_tol)

[pha, amp] = pa_series(data, data,[13,30],[80,200],fs);
assert(abs(pha(1) - 1.57119) < a_tol)

[bins, dist] = pa_dist(pha, amp, 10);
assert(abs(dist(1) - 12.13961) < a_tol)