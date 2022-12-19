function [estim,stdev] = empiric_g(signal,exponent,values)
% EMPIRIC_G computes the function g linking the value of a 1D or 2D process to its exponent.
% To check that the hypothesis that the signal is auto-regulated, it is crucial
% that you check that the estimated standard deviations are small with respect
% to the values of the function g. Otherwise the computed function is meaningless.
%
%   ESTIM = EMPIRIC_G(SIGNAL,EXPONENT) Computes the empirical function g such 
%   that EXPONENT = g(SIGNAL) at 10 values equally spaced between min(SIGNAL)
%   and max(SIGNAL). SIGNAL and EXPONENT must be the same size.
%   ESTIM is a 10x1 vector.
%
%   ESTIM = EMPIRIC_G(SIGNAL,EXPONENT,VALUES) Computes the empirical function g
%   such that EXPONENT = g(SIGNAL) at the points contained in the vector
%   VALUES. SIGNAL and EXPONENT must be the same size.
%   VALUES is a Nx1 vector and ESTIM a Nx1 vector.
%
%   [ESTIM,STDEV] = EMPIRIC_G(SIGNAL,EXPONENT,VALUES) also returns a vector
%   STDEV containing the standard deviation of the estimated exponents, ESTIM.
%   The higher STDEV, the more uncertain the value of ESTIM. STDEV is a Nx1 vector.
% 
%   Example
%
%       randn('seed',100);
%       N=4096; z=linspace(0,1,N); gz = eval('1./(1+5*z.^2)');
%       signal=srmpfbm(N,gz);
%       exponent=estimGQV1DH(signal,0.6,1,[1:1:5]);
%       values=[min(signal):(max(signal)-min(signal))/20:max(signal)];
%       [estim,stdev] = empiric_g(signal,exponent,values);
%       figure;hold on;
%       h1=plot(values,estim);
%       h2=plot(values,estim+2*stdev,'--');plot(values,estim-2*stdev,'--');
%       h3=plot(values,1./(1+5*values.^2),'r');
%       legend([h1,h2,h3],{'Estimation','96 % confidence interval','Function g'});
%
%   See also parametric_g
%
% Reference page in Help browser
%     <a href="matlab:fl_doc empiric_g ">empiric_g</a>

% Auhtor Antoine Echelard, September 2010

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
if nargin<3;values=[min(signal):(max(signal)-min(signal)/10)];end


signal=signal(:);
exponent=exponent(:);

moyennes=(values(2:end)+values(1:end-1))/2;
frontieres=[-Inf,moyennes,Inf];
estim=zeros(1,length(values));
stdev=zeros(1,length(values));
for i=1:length(values);
    indices=find((signal>=frontieres(i))&(signal<frontieres(i+1)));
    estim(i)=nanmean(exponent(indices));
    stdev(i)=nanstd(exponent(indices));
end
