function output = WaterFilter(input,BW,SW)
%Create a Gaussian Bell function
%Width of window set by K - typically 8-32
input(1)=2*input(1);
output=input;
size(output,1);
K=round(0.832*SW/BW);
%K=16;
M=K*2;
k=(-K):1:K;
Gauss=exp(-4*k.^2./K^2);
A=sum(Gauss);
Gauss=Gauss'./A;
for ii=(K+1):(size(input,1)-K-1)
    ii;
    size(Gauss);
    size(real(input((ii+k))));
    output(ii)=sum(real(input((ii+k))).*Gauss)+1i*sum(imag(input((ii+k))).*Gauss);
    
end

for ii=1:K
    ii;
    output(ii)=(output(K+1))+(K+1-ii)/M*((output(K+1))-((output(K+M+1))));
    
end
for ii=(size(output,1)-K):size(output,1)
    ii;
    a=(size(output,1)-K-1);
    b=(size(output,1)-K-M-1);
    output(ii)=output(a)+(ii-(size(output,1)-K+1))/M*(output(a)-(output(b)));
end

dummy=input-output;
output=dummy;
output(1)=output(1)/2.0;

end