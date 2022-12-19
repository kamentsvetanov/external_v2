function [ypred,RMSEP]=plsval(plsmodel,Xtest,ytest,nLV);
%+++ Hongdong Li,Oct.21,2007;
%+++ plsmodel is obtained from the function pls.m in this directory;

if nargin<4;nLV=size(plsmodel.X_scores,2);end;

Xtest=[Xtest ones(size(Xtest,1),1)]; 
ypred=Xtest*plsmodel.coef_origin(:,nLV);
RMSEP=sqrt(sumsqr(ypred-ytest)/length(ytest));

