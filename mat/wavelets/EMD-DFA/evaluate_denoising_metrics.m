function [mse] = evaluate_denoising_metrics(noisy,denoised)

%Computes metrics of denoising (1-D)signal algorithms

%Metrics mean squared error, mean absolute error, signal to noise ratio, peak signal to noise ratio, cross correlation have been computed

%Code published has been by Aditya Sundar, Department of Electrical, Electronics and Instrumentation, BITS Pilani KK Birla Goa Campus/ Texas Instruments 

% Please contact me aditsundar@gmail.com if any issues or message me on https://www.researchgate.net/profile/Aditya_Sundar 

% Some potential applications : Biomedical signal denoising measure (ECG, EEG etc), Audio (speech) signal denoising etc.

temp=noisy;
y=denoised;

%MSE %Mean squared error
mse=0;
for i=1:length(temp)
mse=mse+(y(i)-temp(i))^2;
end
mse=mse/length(temp);
fprintf('mean squared error %f\n',mse);

%MAE %Mean absolute error
mae=0;
for i=1:length(temp)
mae=mae+abs(y(i)-temp(i));
end
mae=mae/length(temp);
fprintf('mean absolute error %f\n',mae);


%SNR and PSNR %signal to noise ratio %peak signal to noise ratio
num=0;
den=0;
for i=1:length(temp)
den=den+(y(i)-temp(i))^2;
end
for i=1:length (temp)
num=num+temp(i)^2;
end
SNR = 20*log10(sqrt(num)/sqrt(den));
PSNR= 20*log10(max(temp)/sqrt(mse));
fprintf('signal to noise ratio %f db\n',SNR);
fprintf('peak signal to noise ratio %f db\n',PSNR);


%Cross correlation 
cc = corrcoef(y,temp);
cross_core = cc(1,2);
fprintf('cross correlation %f\n',cross_core);

end
