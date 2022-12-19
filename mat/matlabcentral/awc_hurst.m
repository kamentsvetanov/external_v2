function h=awc_hurst(data,N,T,wavemode,wave)
%AWC_HURST Calculate the Hurst exponent using the AWC method.
%   H=AWC_HURST(DATA) returns the Hurst exponent H for sample DATA using 
%   the Average Wavelet Coefficient (AWC) method of Simonsen et al. [1].
%   H=AWC_HURST(DATA,N,T,WAVEMODE,WAVE) allows to specify the decomposition
%   level (default: N is the largest power of two such that 2^N is not 
%   greater than the sample size), the vector of powers of two used in the 
%   AWC regression (default: T = 1:(N-1)), the discrete wavelet transform 
%   extension mode (default: WAVEMODE = 'per'; see also dwtmode.m) and 
%   the wavelet type (default: WAVE = 'db24').
%   If there are no output parameters, the AWC statistics is automatically 
%   plotted against the powers of two on a loglog paper and the results of  
%   the analysis are displayed in the command window. 
%
%   Example:
%   >> x = randn(2^14,1);
%   >> awc_hurst(x,14,1:10);
%   For sample applications see Refs. [2-4].
%
%   References:
%   [1] I.Simonsen, A.Hansen, O.Nes (1998) Determination of the Hurst 
%   exponent by use of wavelet transforms, Physical Review E 58, 2779-2787.
%   [2] I.Simonsen (2003) Measuring anti-correlations in the Nordic 
%   electricity spot market by wavelets, Physica A 322, 597-606.
%   [3] R.Weron, I.Simonsen, P.Wilman (2004) Modeling highly volatile and 
%   seasonal markets: evidence from the Nord Pool electricity market, in 
%   "The Application of Econophysics", ed. H. Takayasu, Springer, 182-191.
%   [4] R.Weron (2006) Modeling and Forecasting Electricity Loads and 
%   Prices: A Statistical Approach, Wiley, Chichester.

%   Written by Rafal Weron (2014.06.21). 
%   Based on function awcf.m originally written by Ingve Simonsen & Rafal 
%   Weron (2002.07.27).

% Preliminaries
if nargin<2
    N = floor(log2(length(data)));
else
    % Do not allow for too large values of N
    N = min(N, floor(log2(length(data))));
end
if nargin<3
    T = 1:(N-1);
end
if nargin<4
    % Set the DWT mode to periodization, see dwtmode.m for details
    wavemode = 'per';
end
dwtmode(wavemode,'nodisp');
if nargin<5
    % Daubechies wavelet of order 24
    wave = 'db24';
end

% Wavelet decomposition
DATA = zeros(2^N,1);
DATA(1:length(data)) = data;
[C,L] = wavedec(DATA,N,wave);

% Compute the AWC statistics
awc = zeros(N,1);
sc = zeros(N,1);
for j=1:N,
    awc(j) = mean(abs(detcoef(C,L,j)));
    sc(j) = 2^j;
end

% Compute the Hurst exponent
P = polyfit(log10(sc(T)),log10(awc(T)),1); 
h = P(1) + 0.5;

p = polyfit(sc,log2(awc.^2),1);
% p = polyfit(lvls,log2(stdc.^2),1);

% Plot the results
if nargout<1,
    plot(log10(sc),log10(awc) + log10(sc),'or-',...
        log10(sc),log10(sc)*(P(1)+1) + P(2));
    legend('AWC',['Slope (= H + 0.5), H = ' num2str(h,4)])
    xlabel('log_{10}(Scale)')
    ylabel('log_{10}(AWC)')
    disp('--- AWC estimate of the Hurst exponent ---')
    disp(['H = ' num2str(h,4)])
end
