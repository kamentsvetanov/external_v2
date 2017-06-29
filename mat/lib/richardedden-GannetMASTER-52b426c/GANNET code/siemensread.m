function [A]=  siemensread();

list=dir('*.mat')
size(list)
subjs=size(list,1)/3

for i=1:subjs
under=findstr(list((i-1)*3+1).name, '_')
names{i}=list((i-1)*3+1).name(1:under(1)-1)
reg='_occ_';
file1=strcat(names{i},reg,'ON.mat')
file2=strcat(names{i},reg,'OFF.mat')
file3=strcat(names{i},reg,'diff.mat')
load (file1,'-regexp','^hmm_complex')
A(1:1024,i,1)=hmm_complex;
load (file2,'-regexp','^hmm_complex')
A(1:1024,i,2)=hmm_complex;
load (file3,'-regexp','^hmm_complex')
A(1:1024,i,3)=hmm_complex;
end;

clear file1 file2 file3 hmm_complex i list under subjs ans reg