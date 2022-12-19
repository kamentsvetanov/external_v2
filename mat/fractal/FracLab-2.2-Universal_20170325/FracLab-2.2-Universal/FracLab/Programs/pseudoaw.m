function wig = pseudoaw(x,bounds,voices,varargin)
% PSEUDOAW Computes the Pseudo Affine Wigner distribution of a 1D signal
%
%   WIG = PSEUDOAW(X,BOUNDS,VOICES) Computes the pseudo affine Wigner distribution, WIG, 
%   of the input signal X using the Mexican Hat wavelet and the pseudo Bertrand distribution
%   The parameter BOUNDS is a 2 elements vector, [FMIN,FMAX], FMIN and FMAX are real in (0:0.5)
%   which represent the lower and upper bound frequencies where the analyzis is performed.
%   The parameter VOICES is a positive integer which represents the number of scales computed
%   between FMIN and FMAX frequencies.
%   The ouput signal WIG is a structure that contains the type of data WIG.type which is a cwt
%   and the pseudo affine Wigner distribution, WIG.coeff.
%
%   WIG = PSEUDOAW(...,'WAVEPARAM') or WIG = PSEUDOAW(...,'WAVEPARAM',WAVE) Computes WIG
%   using a specific kind of analyzing wavelet, WAVEPARAM. The possible WAVEPARAM available
%   are 'mexican', in order to use a Mexican Hat wavelet, 'morletr', in order to use a
%   real Morlet wavelet and 'morleta', in order to use an analytic Morlet wavelet. 
%   With Morlet wavelets a positive integer parameter, WAVE, must be defined.
%   If WAVEPARAM is not specified, teh default value is WAVEPARAM = MEXICAN.
%
%   WIG = PSEUDOAW(...'pseudo',K) Computes WIG using a specific pseudo affine parameter, K.
%   The parameter K is a real value and the most common are:
%   K = -1  : pseudo Unterberger  K = 0   : pseudo Bertrand
%   K = 1/2 : pseudo D-Flandrin   K = 2   : pseudo affine Wigner-Ville
%   If PSEUDO is not specified, the default value is K = 0.
%
%   WIG = PSEUDOAW(...,'smooth',SM) Computes WIG using a specific time-smoothing, SM.
%   The parameter SM, a positive integer, is the half length of the time smoothing window.
%   If SMOOTH is not specified, the default value is SM = 0
%
%   Example
%
%       x = Frac_morlet(0.35,32) + Frac_morlet(0.1,32);
%       pawx = pseudoaw(x,[0.01,0.5],128,'morleta',12,'pseudo',-1);
%
%   See also contwt
%
% Reference page in Help browser
%     <a href="matlab:fl_doc pseudoaw ">pseudoaw</a>

% Author Paulo Goncalves, June 1997
% Modified by Christian Choque Cortez, May 2010
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
narginchk(3,9);
nargoutchk(1,1);

if ~(isnumeric(bounds) && size(bounds,1) == 1 && length(bounds) == 2), error('Invalid frequency bounds'); end
if bounds(1) < 0 || bounds(1) > bounds(2) || bounds(2) > 0.5, error('Invalid frequency bounds'); end
if ~(isnumeric(voices) && isscalar(voices) && voices > 0), error('Invalid voices'); end
if voices/floor(voices) ~= 1, error('Invalid voices'); end
if nargin > 3
    arguments = varargin;
    list_wavelet1 = {'morletr','morleta'};
    list_wavelet2 = {'mexican'};

    [waveparam, arguments] = checkforargument(arguments,list_wavelet1,'mexican','wo');
    if strcmp(waveparam{1},'mexican')
        [waveparam, arguments] = checkforargument(arguments,list_wavelet2,'mexican');
    else
        if length(waveparam) ~= 2
            error('Invalid use of waveparam property');
        else
            if waveparam{2}/floor(waveparam{2}) ~= 1, error('The wavelet size must be a positive integer');end
        end
    end
    [k, arguments] = checkforargument(arguments,'pseudo',0);
    if ~(isnumeric(k) && isscalar(k)), error('Invalid use of pseudo property'); end
    [sm, arguments] = checkforargument(arguments,'smooth',0);
    if ~(isnumeric(sm) && isscalar(sm) && sm >= 0), error('Invalid use of smooth property'); end
    if sm > 0 && sm/floor(sm) ~= 1, error('Invalid use of smooth property'); end
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    waveparam = {'mexican'}; k = 0; sm = 0;
end

%--------------------------------------------------------------------------
N = length(x);
fmin = bounds(1); fmax = bounds(2);
if strcmp(waveparam{1},'mexican'), wave = 0; tsupport = (length(mexhat(fmax))-1)/2;
elseif strcmp(waveparam{1},'morletr'), wave = waveparam{2}; tsupport = abs(wave);
elseif strcmp(waveparam{1},'morleta'), wave = waveparam{2}; tsupport = abs(wave);
end

Qte = fmax/fmin; umax = log(Qte); Teq = tsupport/(fmax*umax);
if Teq >= 2*tsupport
    MU = tsupport;
else
    M0 = round((2*tsupport^2)/Teq-tsupport);
    MU = tsupport + M0;
end

kn = 1:voices; q = (fmax/fmin)^(1/(voices-1));
a = (exp((kn-1).*log(q)));  % a is an increasing scale vector.
f(kn) = fmin*a;         % f is a geometrical increasing frequency vector.

% Wavelet computation
if wave == 0
    wt = contwt(x,[f(1),f(voices)],voices,waveparam{1}) ;
else
    wt = contwt(x,[f(1),f(voices)],voices,waveparam{1},wave) ;
end
wt = wt.coeff;
wtnonorm = zeros(size(wt)) ;

for ptr = 1:voices,
    wtnonorm(ptr,:) = wt(ptr,:).*sqrt(a(ptr)) ;
end

% Pseudo Affine Wigner distribution computation
coefficients=zeros(size(wt));
umin = -umax; u=linspace(umin,umax,2*MU+1); u(MU+1) = 0;
kn = 1:2*voices;
beta(kn) = -1/(2*log(q))+(kn-1)./(2*voices*log(q));

for m = 1:2*MU+1
    l1(m,:) = exp(-(2*i*pi*beta).*log(lambdak(u(m),k)));
end

% NEW DETERMINATION OF G(T) (cf. pp.148 notebook Rice)
a_t = 3;    % (attenuation of 10^(-a_t) at t = tmax)
sigma_t = sm*fmax/sqrt(2*a_t*log(10));
a_u = 2 * pi^2 * sigma_t^2 * umax^2 / log(10);
sigma_u = inf;
if sigma_t ~= 0, sigma_u = 1/(2 * pi * sigma_t); end
if sigma_u < umax/MU
    fenh = findobj('Tag','Fig_gui_fl_pseudoaw');
    if isempty(fenh)
        disp('maximum time-smoothing corresponding to the scalogram reached');
    else
        fl_warning('maximum time-smoothing corresponding to the scalogram reached ');
    end
end

G = gauss(2*MU+1,a_u); G = G(1:2*MU);
G = G(ones(1,voices),:)';

for ti = 1:N
    S = zeros(1,2*voices);
    S(voices:-1:1) =  wtnonorm(:,ti);
    S(voices+1:2*voices) = zeros(1,voices);
    Mellin = fftshift(ifft(S));
    MX1 = l1.*Mellin(ones(1,2*MU+1),:);
    X1 = fft(MX1.') ; X1 = X1(1:voices,:).';
    waf = real(X1(1:2*MU,:).*conj(X1(2*MU+1:-1:2,:)).*G) ;
    coefficients(voices:-1:1,ti) = (sum(waf).*f).';
end
wig = struct('type','cwt','coeff',coefficients);
end
%--------------------------------------------------------------------------
function y = lambdak(u,k)
% Computes the parametrizing function lambdak defining the Affine Wigner distributions.

ind = find(u ~= 0);
y = ones(size(u));

if k == 0    
    y(ind) = -u(ind)./(exp(-u(ind))-1);
elseif k == 1
    y(ind) = exp(1+u(ind).*exp(-u(ind))./(exp(-u(ind))-1));
else
    y(ind) = (k*(exp(-u(ind))-1)./(exp(-k*u(ind))-1)).^(1/(k-1));
end
    
end
