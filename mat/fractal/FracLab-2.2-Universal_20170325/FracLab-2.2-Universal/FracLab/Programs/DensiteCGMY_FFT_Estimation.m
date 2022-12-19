function [x,y]=DensiteCGMY_FFT_Estimation(t,C,G,M,Y,Model)
% fonction carachteristique
yy=Phi_CGMY(Model.xx,t,C,G,M,Y);
%  FFT
yy1 = [yy((2^(Model.n-1)+1):2^Model.n), yy(1:2^(Model.n-1))];
z = real( fft(yy1) )/(2*pi)*Model.R;%fft
% densité 
% x = (2*pi)*((0:1:(Model.M-1))/(Model.M*Model.R)-1/(2*Model.R));
y = [z((2^(Model.n-1)+1):2^Model.n), z(1:2^(Model.n-1))];
% Passage à l'intevale origine
x = Model.x(Model.T); x = x(:);
y = y(Model.T); y = y(:);
end