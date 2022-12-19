function wt = contwt(x,bounds,voices,varargin)
% CONTWT Computes the Continous Wavelet Transform of a 1D signal
%
%   WT = CONTWT(X,BOUNDS,VOICES) Computes the continous L2 wavelet transform, WT, 
%   of the input signal X using the Mexican Hat wavelet. The parameter BOUNDS
%   is a 2 elements vector, [FMIN,FMAX], FMIN and FMAX are real values in (0:0.5)
%   which represent the lower and upper bound frequencies where the analyzis 
%   is performed. The parameter VOICES is a positive integer which represents
%   the number of scales computed between FMIN and FMAX frequencies.
%   The ouput signal WT is a structure that contains the type of data WT.type
%   which is a cwt and the continous wavelet transform, WT.coeff.
%   For arbitrary analyzing wavelets, numerical approximation is achieved using
%   a Fast Mellin Transform.
%
%   WT = CONTWT(...,'WAVEPARAM') or WIG = CONTWT(...,'WAVEPARAM',WAVE) Computes WT
%   using a specific kind of analyzing wavelet, WAVEPARAM. The possible WAVEPARAM
%   available are 'mexican', in order to use a Mexican Hat wavelet, 'morletr', in
%   order to use a real Morlet wavelet and 'morleta', in order to use an analytic
%   Morlet wavelet. With Morlet wavelets a positive integer parameter, WAVE,
%   must be defined.
%   If WAVEPARAM is not specified, the default value is WAVEPARAM = MEXICAN.
%
%   WT = CONTWT(...,'MIRRORING') Computes WT with MIRRORING options. The possible
%   MIRRORING options that can be applied are 'mirror' in order to compute WT with
%   mirroring of the input signal X, or 'nomirror' to compute WT without mirroring.
%   IF MIRRORING is not specified, the default value is MIRRORING = NOMIRROR.
%
%   WT = CONTWT(...,'NORM') Computes WT with NORM options. The possible NORM
%   options that can be applied are 'L1' in order to perform the computation with
%   an L1 normalization or 'L2' in order to perform the computation with an
%   L2 normalization.
%   If NORM is not specified, the default value is NORM = L2.
%
%   Example
%
%       x = Frac_morlet(0.1,128);
%       wt = contwt(x,[0.01,0.5],128,'morleta',8);
%
%       xm = ones(1,128); xm(64) = 0;
%       wtm = contwt(xm,[2^(-6),2^(-1)],128,'mirror');
%
%   See also pseudoaw
%
% Reference page in Help browser
%     <a href="matlab:fl_doc contwt ">contwt</a>

% Author Bertrand Guiheneuf, February 1997 (for cwt C code)
% Author Paulo Goncalves, June 1997
% Modified by Christian Choque Cortez, May 2010
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
narginchk(3,7);
nargoutchk(1,2);

if ~(isnumeric(bounds) && size(bounds,1) == 1 && length(bounds) == 2), error('Invalid frequency bounds'); end
if bounds(1) < 0 || bounds(1) > bounds(2) || bounds(2) > 0.501, error('Invalid frequency bounds'); end
if ~(isnumeric(voices) && isscalar(voices) && voices > 0), error('Invalid voices'); end
if voices/floor(voices) ~= 1, error('Invalid voices'); end
if nargin > 3
    arguments = varargin;
    list_wavelet1 = {'morletr','morleta'};
    list_wavelet2 = {'mexican'};
    list_mirror = {'nomirror','mirror'};
    list_space = {'L2','L1'};

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
    [mirrorparam, arguments] = checkforargument(arguments,list_mirror,'nomirror');
    if strcmp(mirrorparam{:},'nomirror'), mirror = 0; else mirror = 1; end
    [normparam, arguments] = checkforargument(arguments,list_space,'L2');
    if strcmp(normparam{:},'L2'), L2 = 1; else L2 = 0; end
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    waveparam = {'mexican'}; mirror = 0; L2 = 1;
end

%--------------------------------------------------------------------------
N = length(x);
fmin = bounds(1); fmax = bounds(2);
if strcmp(waveparam{1},'mexican'), wave = 0; 
elseif strcmp(waveparam{1},'morletr'), wave = waveparam{2}; 
elseif strcmp(waveparam{1},'morleta'), wave = waveparam{2}*i; 
end

if ~L2
    coefficients = cwt(x,fmin,fmax,voices,abs(wave)); % calling the mex-file
else
    freq = logspace(log10(fmax),log10(fmin),voices);
    scale = logspace(log10(1),log10(fmax/fmin),voices);

    if length(wave) == 1
        if wave == 0
            if ~mirror
                for ptr = 1:voices
                    ha = mexhat(freq(ptr)); nha = (length(ha)-1)/2;
                    detail = conv(x,ha);
                    coefficients(ptr,:) = detail(nha+1:nha+N);
                end
            else
                for ptr = 1:voices
                    ha = mexhat(freq(ptr)); nha = (length(ha)-1)/2; nbmir = min(N,nha);
                    try 
                        x_mir = [x(nbmir:-1:2) x x(N-1:-1:N-nbmir+1)];
                    catch %#ok<CTCH>
                        x_mir = [x(nbmir:-1:2);x;x(N-1:-1:N-nbmir+1)];
                    end
                    detail = conv(x_mir,ha);
                    coefficients(ptr,1:N) = detail(nha+nbmir:nha+nbmir+N-1);
                end
            end
        else
            nh0 = abs(wave);
            if ~mirror
                for ptr = 1:voices
                    nha = round(nh0 * scale(ptr));
                    ha = conj(Frac_morlet(freq(ptr),nha,~isreal(wave)));
                    detail = conv(x,ha);
                    coefficients(ptr,1:N) = detail(nha+1:nha+N);
                end
            else
                for ptr = 1:voices
                    nha = round(nh0 * scale(ptr));
                    ha = conj(Frac_morlet(freq(ptr),nha,~isreal(wave))); nbmir = min(N,nha);
                    try
                        x_mir = [x(nbmir:-1:2) x x(N-1:-1:N-nbmir+1)];
                    catch %#ok<CTCH>
                        x_mir = [x(nbmir:-1:2);x;x(N-1:-1:N-nbmir+1)];
                    end
                    detail = conv(x_mir,ha);
                    coefficients(ptr,1:N) = detail(nha+nbmir:nha+nbmir+N-1);
                end
            end
        end
    else
        wavef = fft(wave); nwave = length(wave);
        f0 = find(abs(wavef(1:nwave/2)) == max(abs(wavef(1:nwave/2))));
        f0 = mean((f0-1).*(1/nwave));
        scale = logspace(log10(f0/fmax),log10(f0/fmin),voices);
        B = 0.99; R = B/((1.001)/2);
        nscale = max(128,round((B*nwave*(1+2/R)*log((1+R/2)/(1-R/2)))/2));
        wavescaled = real(Frac_dilate(wave,scale,0.001,0.5,nscale));
        if ~mirror
            for ptr = 1:voices
                ha = wavescaled(2:wavescaled(1,ptr),ptr);
                firstindice = (wavescaled(1,ptr)-rem(wavescaled(1,ptr),2))/2;
                detail = conv(x,ha);
                detail = detail(firstindice+1:firstindice+N);
                coefficients(ptr,1:N) = detail(:).';
            end
        else
            for ptr = 1:voices
                ha = wavescaled(2:wavescaled(1,ptr),ptr) ;
                firstindice = (wavescaled(1,ptr)-rem(wavescaled(1,ptr),2))/2;
                nbmir = min(N,firstindice);
                try
                    x_mir = [x(nbmir:-1:2) x x(N-1:-1:N-nbmir+1)];
                catch %#ok<CTCH>
                    x_mir = [x(nbmir:-1:2);x;x(N-1:-1:N-nbmir+1)];
                end
                detail = conv(x_mir,ha);
                detail = detail(firstindice+nbmir:firstindice+nbmir+N-1);
                coefficients(ptr,1:N) = detail(:).' ;
            end
        end
    end
end
wt = struct('type','cwt','coeff',coefficients,'scale',scale);
end
