function [I,NextSigma,NextdeltaMu] = expBinom(x,mu,va,p)
% OTO: varational energy (and curvature) of associative strength
in.G0 = 1;
in.beta = 1;
[sx] = sigm(x,in);
lsx = log(sx);
if ~isinf(va)
    iva = va.^-1;
else
    iva = 0;
end
I = -0.5.*iva*(x-mu).^2 + (p-1).*x + lsx;
d2lsx = sx.^2 - sx;
NextSigma = (iva + -d2lsx).^-1;
NextdeltaMu = NextSigma*(iva*(mu-x(:))+p-sx(:));




