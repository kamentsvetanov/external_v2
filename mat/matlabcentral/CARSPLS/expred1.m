function expred1(yexp,ypred)
%+++ yexp and ypred are both column vector
%+++ yexp: experimental values
%+++ ypred: predicted values


if size(yexp,1)==1;yexp=yexp';end
if size(ypred,1)==1;ypred=ypred';end

plot(yexp,ypred,'+');
min1=min([yexp;ypred]);
max1=max([yexp;ypred]);
d=(max1-min1)/50;
axis([min1-d max1+d min1-d max1+d]);
line45=linspace(min1,max1,20);
hold on;plot(line45,line45,'g-');
xlabel('Experimental');ylabel('Predicted');




