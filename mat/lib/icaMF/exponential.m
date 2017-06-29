function [f,df] = exponential(gamma,lambda,par)
eta=1;
erfclimit=-135;
%minlambda=10^-4;
%lambda=lambda.*(lambda>minlambda)+minlambda.*(lambda<=minlambda);
xi=(gamma-eta)./sqrt(lambda);
cc=(xi>erfclimit);
xi1=xi.*cc;
epfrac=exp(-(xi1.^2)/2)./(Phi(xi1)*sqrt(2*pi));
f=cc.*(xi1+epfrac)./sqrt(lambda);            % need to go to higher order to get asymptotics right
if nargout > 1
    df=(1./lambda+f.*(xi1./sqrt(lambda)-f)); % need to go to higher order to get asymptotics right -fix at some point!!!
end

% Phi (error) function
function y=Phi(x)
% Phi(x) = int_-infty^x Dz 
z=abs(x/sqrt(2));
t=1.0./(1.0+0.5*z);
y=0.5*t.*exp(-z.*z-1.26551223+t.*(1.00002368+...
    t.*(0.37409196+t.*(0.09678418+t.*(-0.18628806+t.*(0.27886807+...
    t.*(-1.13520398+t.*(1.48851587+t.*(-0.82215223+t.*0.17087277)))))))));
y=(x<=0.0).*y+(x>0).*(1.0-y);
