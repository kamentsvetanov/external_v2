function [] = emd_dfadenoising (a)

%Denoising using EMD-DFA
%code published by Aditya Sundar, Texas Instruments/ BITS Pilani K.K. Birla Goa Campus
%Please contact me on aditsundar@gmail.com for any queries
tic
plot(a);
imf= emd(a); %Computes the EMD
imf=imf' ;	  %Store the IMFs as column vectors 
s=size(imf)
h=zeros(1,s(2));
b=a';
for i=1:s(2)
h(i)=estimate_hurst_exponent(imf(:,i)');
if(h<0.5)
b=b-imf(:,i)' ;
%figure(i+10)         %incase you want to see the IMFs
%plot(imf(:,i)')
end
end
figure(2)
plot(b)
toc
evaluate_denoising_metrics(a,b) 	%evaluates denoising metrics
end
