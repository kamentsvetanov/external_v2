function [wt,wti,wtl] = FWT(x,nl,filter1,varargin)
% FWT Computes the Forward Discrete Wavelet Transform of a 1D signal
%
%   WT = FWT(X,NL,FILTER1) Computes the discrete wavelet transform, WT of
%   the input signal X. WT is an orthogonal transform is computed using a 
%   number of decomposition levels, NL, and the analysis filter, FILTER1. 
%   The parameter NL is a positive integer bigger than 1 and should not exceed
%   NL = log2(length(x)).
%
%   WT = FWT(...,FILTER2) Computes the biorthogonal transform, WT, 
%   using a second filter, FILTER2.
%
%   [WT,WTI,WTL] = FWT(...) Computes WT and returns the vectors WTI and WTL.
%   WTI contains the indexes in WT of the projection of the input signal 
%   on the multiresolution subspaces. WTL contains the dimension of each
%   projection.
%
%   WT = FWT(X,NL,FILTER1,0,STRUCT) or WT = FWT(X,NL,FILTER1,FILTER2,STRUCT)
%   Computes WT,WTI and WTL using the boolean STRUCT. 
%       STRUCT = 1 The ouput signal WT is a structure that contains the type
%                  of data WT.type which is a dwt, the discrete wavelet transform,
%                  WT.wt, the indexes WT.index and the dimension WT.length.
%
%   Example
%
%       x = rand(1,256); q=MakeQMF('daubechies',4);
%       [wt,wti,wtl] = FWT(x,6,q);
%       M = WTMultires(wt);
%       figure; plot(M(2,:));
%       xlim([0 length(wt)]); title('Multiresolution representation');
%       % Eliminate the Lowest Frequency component and reconstruct:
%       for i=1:wtl(6), wt(wti(6)+i-1) = 0; end;
%       y = IWT(wt);
%       figure;plot(y); 
%       xlim([0 length(y)]); title('Inverse discrete wavelet transform');
%
%   See also IWT, MakeQMF, MakeCQF, WTStruct, WTNbScales, WTMultires
%
% Reference page in Help browser
%     <a href="matlab:fl_doc FWT ">FWT</a>

% Auhtor Bertrand Guiheneuf, June 1997
% Modified by Christian Choque Cortez, May 2010
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
narginchk(3,5);
nargoutchk(1,3);

if ~(isnumeric(nl) && isscalar(nl) && nl >= 1), error('Invalid number of levels'); end
if ~isnumeric(filter1), error('Invalid filter'); end
filter2 = 0; structure = 0;
try %#ok<TRYNC>
    filter2 = varargin{1};
    structure = varargin{2};
end
if ~isnumeric(filter2), error('Invalid second filter'); end
if ~(isnumeric(structure) && structure == 0 || structure == 1), error('5th input only a boolean'); end

%--------------------------------------------------------------------------
N=length(x); n=log2(N);

if n == floor(log2(N));
   xx = x;
else
   xx = zeros(1,2^(floor(log2(N))+1));
   xx(1:N) = x;
end 

if ~filter2
    [wt,wti,wtl]= DWT1D(xx,nl,filter1); % calling the mex-file
else
    [wt,wti,wtl]= DWT1D(xx,nl,filter1,filter2); % calling the mex-file
end

if structure, wt = struct('type','dwt','wt',wt,'index',wti,'length',wtl); end

end
