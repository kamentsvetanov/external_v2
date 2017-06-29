function [Output phase] = FixCrPhase(Input,range)
%Function take a complex spectrum and maximises the real integral over range
step=5;
integral=zeros([1 360/step]);
for ii=step:step:360
    integral(ii/step)=max(real(Input(range)*exp(1i*pi/180*ii)));
end
[dummy,index] = max(integral);
% figure(11)
% plot(step:step:360,integral)
% stop here
phase=index*step;
    Output=Input*exp(1i*pi/180*phase);
end