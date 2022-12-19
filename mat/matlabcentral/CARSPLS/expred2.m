function expred(ycalexp,ycalpred,ytestexp,ytestpred)
%+++ to plot the y-value in calibration set and test set in the same plot
%+++ Apr.20,2008. Hongdong Li

expredsub(ycalexp,ycalpred,'k+');
expredsub(ytestexp,ytestpred,'kd');

%+++ subfunctions
function expredsub(yexp,ypred,string)
%+++ yexp and ypred are both column vector
%+++ yexp: experimental values
%+++ ypred: predicted values


if size(yexp,1)==1;yexp=yexp';end
if size(ypred,1)==1;ypred=ypred';end

plot(yexp,ypred,string);
min1=min([yexp;ypred]);
max1=max([yexp;ypred]);
d=(max1-min1)/30;
axis([min1-d max1+d min1-d max1+d]);
line45=linspace(min1-d,max1+d,20);
hold on;plot(line45,line45,'k-');
xlabel('Experimental');ylabel('Predicted');




