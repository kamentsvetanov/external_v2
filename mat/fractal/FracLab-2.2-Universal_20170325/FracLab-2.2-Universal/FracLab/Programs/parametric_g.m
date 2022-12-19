function [estim,minerr,maxerr] = parametric_g(signal,values,percentage,M)
% PARAMETRIC_G computes the function g linking the value of a 1D process to its exponent,
% under the hypothesis that the signal is a midpoint displacement self regulated process.
% Note that PRAMETRI_G will always compute a function g even if the input signal
% is not a self regulating process. In consequence you must check beforehand that
% this assumption is verified. In that view, you may run EMPIRIC_G.
%
%   ESTIM = PARAMETRIC_G(SIGNAL) computes the function g such that EXPONENT = g(SIGNAL)
%   at 10 values equally spaced between min(SIGNAL) and max(SIGNAL)under the
%   hypothesis that the signal is a midpoint displacement auto-regulated process
%   with amplitude parameter M=1. ESTIM is a 10x1 vector.
%
%   ESTIM = PARAMETRIC_G(SIGNAL,VALUES) computes the empirical function g
%   such that EXPONENT = g(SIGNAL) at the points contained in the vector
%   VALUES. VALUES is a Nx1 vector and ESTIM a Nx1 vector.
%
%   [ESTIM,MINERR,MAXERR] = PARAMETRIC_G(SIGNAL,VALUES,PERCENTAGE) also returns a 
%   vector MINERR containing the minimum of a confidence interval with a 
%   PERCENTAGE for the estimation of g, and MAXERR its maximum. If VALUES is an 
%   Nx1 vector, then MINERR and MAXERR are also Nx1 vectors. Moreover, G
%   must not vary "too much" on an interval for the confidence interval to be pertinent.
% 
%   [ESTIM,MINERR,MAXERR] = PARAMETRIC_G(SIGNAL,VALUES,PERCENTAGE,M) returns the
%   evaluation and the confidence interval of G, under the hypothesis that the 
%   signal is a midpoint displacement auto-regulated process with amplitude parameter M.
%
%   Example 1
%
%       randn('seed',1000)
%       gz='0.2'; N=4096; M=0.5;
%       percentage=14/100; 
%       X=srmpmidpoint(N,gz,'ampli',M);
%       maxi=max(X); mini=min(X); pas=(maxi-mini)/100;
%       values=[mini+pas/2:pas:maxi-pas/2];
%       [estim,minerr,maxerr]=parametric_g(X,values,percentage,M);
%       %The error percentage is approximately equal to "percentage". 
%       Number_of_errors=sum(0.2<minerr)+sum(0.2>maxerr);
%       Error_percentage=Number_of_errors/sum(isfinite(estim))
%       figure;hold on;
%       h1=plot(values,estim);
%       h2=plot(values,minerr,'--');plot(values,maxerr,'--');
%       h3=plot(values,0.2*ones(size(values)),'r');
%       legend([h1,h2,h3],{'Estimation','86 % confidence interval','Function g'});
%
%   Example 2
%
%       N=4096;
%       gz='1./(1+5*z.^2)';
%       randn('seed',1000)
%       percentage=10/100;
%       pcent_sortis=[];
%       X=srmpmidpoint(N,gz);%,'ampli',0.8);
%       maxi=max(X); mini=min(X); pas=(maxi-mini)/100;
%       values=[mini+pas/2:pas:maxi-pas/2];
%       [estim,minerr,maxerr]=parametric_g(X,values,percentage);
%       figure;hold on;
%       h1=plot(values,estim);
%       h2=plot(values,minerr,'--');plot(values,maxerr,'--');
%       h3=plot(values,1./(1+5*values.^2),'r');
%       legend([h1,h2,h3],{'Estimation','86 % confidence
%       interval','Function g'});
%       pas=(maxi-mini)/20;
%       values=[mini+pas/2:pas:maxi-pas/2];
%       [estim,minerr,maxerr]=parametric_g(X,values,percentage);
%       figure;hold on;
%       h1=plot(values,estim);
%       h2=plot(values,minerr,'--');plot(values,maxerr,'--');
%       h3=plot(values,1./(1+5*values.^2),'r');
%       legend([h1,h2,h3],{'Estimation','86 % confidence interval','Function g'});
%
%   See also empiric_g
%
% Reference page in Help browser
%     <a href="matlab:fl_doc parametric_g ">parametric_g</a>

% Auhtor Antoine Echelard, September 2010

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
if nargin<4;M=[];end
if nargin<3;percentage=[];end
if nargin<2;values=[];end

if isempty(M);M=1;end
if isempty(percentage);percentage=4/100;end
if isempty(values);values=[min(signal):(max(signal)-min(signal))/10:max(signal)];end

moyenne=[(signal(1:2:end-2)+signal(3:2:end))/2];% Param
V2=signal(2:2:end);
V2=V2(1:length(moyenne));
tir2=(V2-moyenne)/M;

N=length(signal);

milieux=(values(2:end)+values(1:end-1))/2;
frontieres=[-Inf,milieux,Inf];

for i=1:length(values)
    indices=find((moyenne>=frontieres(i))&(moyenne<frontieres(i+1)));
    Nbpts=length(indices);

    if Nbpts>0
        u=chi2inv(percentage/2,Nbpts);
        v=chi2inv(1-percentage/2,Nbpts);

        z_diff=tir2(indices);
        estim_lambda=(nanmean(z_diff.^2))^(1/(2));% Param
        estim(i)=log(estim_lambda)/(-log(length(signal)));% Param

        T=sum(z_diff.^2);
        minerr(i)=log(u)/(2*log(N))-log(T)/(2*log(N));
        maxerr(i)=log(v)/(2*log(N))-log(T)/(2*log(N));
    else
        estim(i)=NaN;
        minerr(i)=NaN;
        maxerr(i)=NaN;
    end
end


