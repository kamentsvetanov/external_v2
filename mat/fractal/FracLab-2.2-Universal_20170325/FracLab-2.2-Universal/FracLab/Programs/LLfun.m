%------numerical likelihood function------
function[LLf]=LLfun(t,C,G,M,Y,Model)
[x,y]=DensiteCGMY_FFT_Estimation(t,C,G,M,Y,Model);
xx=(Model.data);
Y=spline(x,y,xx);
LLf=-sum(log(Y));
end