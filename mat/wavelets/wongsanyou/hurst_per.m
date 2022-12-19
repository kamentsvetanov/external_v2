function [H, P] = hurst_per(sequence, fs, range)
% HURST_PER  Estimation of the hurst parameter of a given sequence with periodogram method.
%
% Syntax:
%   H = bfn_per(sequence, fs, range)
%
% Description:
%   It estimates the hurst parameter of a given sequence based on the
%   periodogram method.
%
% Input Arguments:
%   sequence    - the input sequence for estimate 
%
% Options:
%   range 		- a single value or an 1x2 vector for the percentage
%              		range of frequencies to estimate the Hurst
%                 	exponent. Default is 0.02. 
%   fs        	- the sampling frequency. Default is 1000 Hz.
%
% Output Arguments:
%   H           - the estimated hurst coeffeient of the input sequence.
%   P           - the periodogram of input sequence.
%
% Examples:
%   x = normrnd(0,1,1000,1);
%   H = hurst_per(x);
%
%__________________________________________________________________________
% Original from Chu Chen(chen-chu@163.com), Modified by Wonsang You(wsgyou@gmail.com)
% 7/14/2016
% Copyright (c) 2016 Wonsang You.


%% initialization

if nargin < 2 || isempty(fs)
	fs = 1000;
end

if nargin < 3 || isempty(range)
	range = 0.02;
end


%% demeaning
sequence = sequence - mean(sequence);


%% compute power spectrum
n           = length(sequence);
NFFT        = 2^nextpow2(n);
Xk          = fft(sequence,NFFT);
P_origin    = abs(Xk).^2/(n);
lenP        = floor(NFFT/2)+1;
P           = P_origin(1:lenP);


%% compute the Hurst exponent
f   = fs/2*linspace(0,1,lenP);
x   = log10(f(2:end));
y   = log10(P(2:end));
y   = squeeze(y);
y   = y';

lower = floor(range(1)*lenP);
if lower < 1
    lower = 1;
end
upper = ceil(range(2)*lenP);
if upper > lenP
    upper = lenP;
end

X = x(lower:upper);
Y = y(lower:upper);
if size(X)~=size(Y)
    Y = Y';
end

p1 = polyfit(X,Y,1);
Yfit = polyval(p1,X);
H = 0.5-(Yfit(end)-Yfit(1))/(X(end)-X(1))/2;
