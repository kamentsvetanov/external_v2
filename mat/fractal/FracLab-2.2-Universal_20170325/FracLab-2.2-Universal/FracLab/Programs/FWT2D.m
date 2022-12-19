function [wt,wti,wtl] = FWT2D(x,nl,filter1,varargin)
% FWT2D Computes the Forward Discrete Wavelet Transform of a 2D signal
%
%   WT = FWT2D(X,NL,FILTER1) Computes the discrete wavelet transform, WT of
%   the input signal X. WT is an orthogonal transform using a number of decomposition
%   levels, NL, and the analysis filter, FILTER1. The parameter NL is a positive
%   integer bigger than 1 and should not exceed NL = log2(min(size(x))).
%
%   WT = FWT2D(...,FILTER2) Computes the biorthogonal transform, WT, using
%   a second filter, FILTER2.
%
%   [WT,WTI,WTL] = FWT2D(...) Computes WT and returns the vectors WTI and WTL.
%   WTI contains the indexes in WT of the projection of the input signal 
%   on the multiresolution subspaces. WTL contains the dimension of each
%   projection.
%
%   WT = FWT2D(X,NL,FILTER1,0,STRUCT) or WT = FWT2D(X,NL,FILTER1,FILTER2,STRUCT)
%   Computes WT,WTI and WTL using the boolean STRUCT. 
%       STRUCT = 1 The ouput signal WT is a structure that contains the type
%                  of data WT.type which is a dwt2d, the discrete wavelet transform,
%                  WT.wt, the indexes WT.index and the dimension WT.length.
%
%   Example
%
%       x = rand(256,256); q = MakeQMF('daubechies',4);
%       [wt,wti,wtl] = FWT2D(x,3,q);
%       V = WT2Dext(wt,1,2);
%       figure; viewmat(V);
%       % Eliminate the Lowest Frequency component and reconstruct:
%       index=0;
%       for i=1:wtl(3,1),for j=1:wtl(3,2), wt(wti(3,4)+index) = 0; end; end;
%       y = IWT2D(wt);
%
%   See also IWT2D, MakeQMF, MakeCQF, WT2DStruct, WT2Dext, WT2DVisu
%
% Reference page in Help browser
%     <a href="matlab:fl_doc FWT2D ">FWT2D</a>

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
[N1,N2] = size(x); nx = log2(N1); ny = log2(N2);

if nx == floor(log2(N1)) && ny == floor(log2(N2));
   xx = x;
elseif nx == floor(log2(N1))
   xx = zeros(N1,2^(floor(log2(N2))+1));
   xx(1:N1,1:N2) = x;
elseif ny == floor(log2(N2));
   xx = zeros(2^(floor(log2(N1))+1),N2);
   xx(1:N1,1:N2) = x;
else 
   xx = zeros(2^(floor(log2(N1))+1),2^(floor(log2(N2))+1));
   xx(1:N1,1:N2) = x;
end 

if ~filter2
    [wt,wti,wtl]= DWT2D(xx,nl,filter1); % calling the mex-file
else
    [wt,wti,wtl]= DWT2D(xx,nl,filter1,filter2); % calling the mex-file
end

if structure, wt = struct('type','dwt2d','wt',wt,'index',wti,'length',wtl); end

end
