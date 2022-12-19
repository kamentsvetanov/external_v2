function A = alphaimage(X,Rmax,varargin)
% ALPHAIMAGE Computes corresponding alpha image from original, normalized, image.
%            The pixels in the alpha image are estimated values of Holder
%            exponent at these points and they describe the local regularity.
%
%   A = alphaimage(X,RMAX) Estimates the Holder "alpha" image, A, of the
%   normalized grayscale input image, X using a specific radius, RMAX. The
%   parameter RMAX is an integer in (1:5) which defines the largest measure domain.
%
%   A = alphaimage(...,'METHOD') Estimates A using a specific measure type,
%   METHOD. The supported measure types are 'max','min','sum','iso' for
%   square shaped domains and 'mini', 'maxi' for diamond shaped domains.
%   If METHOD is not specified, the default value is METHOD = MINI.
%
%   A = alphaimage(...,'SCALE') Estimates A using a specific grayscale of
%   the image. The possible SCALE options that can be applied are 'neg', in 
%   order to use the negative image of X or 'normal' in order to use the original 
%   image, X. If SCALE is not specified, the default value is SCALE = NORMAL.
%
%   Example
%
%       images_loc = which('alphaimage.html');
%       x = imread(fullfile(fileparts(images_loc),'images_examples','Segmentation','m213.pgm'));
%       x = ima2mat(x);
%       A = alphaimage(x,2,'neg');
%       figure; subplot(1,2,1); imagesc(x); title('Negative image of x');
%       subplot(1,2,2); imagesc(A); title('Alpha image');
%
%   See also falphaimage, spotted
%
%   References
%       [1] J. Lévy-Véhel, P. Mignot "Multifractal segmentation of images",
%           Fractals, Vol. 2, No. 3 (1994) 379-382.
%
%       [2] T. Stojic, I. Reljin, B. Reljin "Adaptation of multifractal analysis 
%           to segmentation of microcalcifications in digital mammograms", Physica A: 
%           Statistical Mechanics and its Applications, Vol. 367 (15), (2006) 494-508.
%
% Reference page in Help browser
%     <a href="matlab:fl_doc alphaimage ">alphaimage</a>

% Author Tomislav Stojic, Irini Reljin, Branimir Reljin, University of Belgrade-Serbia, July 2004
% Modified by Christian Choque Cortez, September 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(2,5)
nargoutchk(1,1)

if nargin > 2
    arguments = varargin;
    list_method1 = {'iso'};
    list_method2 = {'mini','maxi','min','max','sum'};

    [method, arguments] = checkforargument(arguments,list_method1,'mini','wo');
    if strcmp(method{1},'iso')
        try sensibility = method{2}; catch, sensibility = 200; end %#ok<NOCOM,CTCH>
    end
    if strcmp(method{1},'mini')
        [method, arguments] = checkforargument(arguments,list_method2,'mini');
    end
    [scale, arguments] = checkforargument(arguments,{'neg'},'normal');

    if isnumeric(method), error('Invalid use of method property'); end
    if ~isempty(arguments), error('Too many input arguments'); end
else
    scale = {'normal'};
    method = {'mini'};
end
if Rmax < 0 || Rmax > 5, error('Invalid Radius argument input'); end
%--------------------------------------------------------------------------

if strcmp(scale,'neg')
    X = 1 - double(X)/double(max(X(:))); % Negative grayscale image
else
    X = double(X); % Image without inversion
end

X(X==0) = 1/255; % to avoid log(0)
[m,n] = size(X); % original image dimensions
A = zeros(m,n);  % aplha image initialization
brojciklusa = 1 + Rmax; % number of loops
M = zeros(m,n,brojciklusa); % image of measures

red = [1,9,25,49,81,121,169,225,289]; % number of active pixels for sqaure domains
nhood = [1,3,5,7,9,11,13,15,17]; % neighborhood dimensions
LogDim =- log([1 1/3 1/5 1/7 1/9 1/11 1/13 1/15]); % log(domain sizes) calculation
Domain = domeni; % diamond shaped domains

switch (method{1})
    case 'maxi' % maximum measure, diamond shaped domains
        [M(:,:,1)] = log(X); % log (measure image for one pixel domain)
        for k = 2:brojciklusa
            broj1 = size(find(Domain(k-1).dom==1),1); % number of active pixels
            P = my_ordfilt2(X,broj1,Domain(k-1).dom); % image of maximums in diamond shaped measure domains
            [M(:,:,k)] = log(P); % log(maximum image)
        end

    case 'max' % maximum measure, square shaped domains
        [M(:,:,1)] = log(X);
        for k = 2:brojciklusa
            P = my_ordfilt2(X,red(k),ones(nhood(k),nhood(k))); % image of maximums in square shaped measure domain
            [M(:,:,k)] = log(P);  % log(maximum image)
        end

    case 'mini' % minimum measure, diamond shaped domains
        [M(:,:,1)] = log(X); % log (measure matrix for one pixel domain)
        for k = 2:brojciklusa
            P = my_ordfilt2(X,1,Domain(k-1).dom); % image of minimums in diamond shaped measure domains
            [M(:,:,k)] = log(P); % log(minimum image)
        end

    case 'min' % minimum measure, square shaped domains
        [M(:,:,1)] = log(X);
        for k = 2:brojciklusa
            P = my_ordfilt2(X,1,ones(nhood(k),nhood(k)));
            [M(:,:,k)] = log(P); % log(minimum image)
        end

    case 'sum' % sum measure, square domains
        [M(:,:,1)] = log(X);
        for k = 2:brojciklusa
            P = my_colfilt(X,[nhood(k) nhood(k)]); % image of sums in diamond shaped measure domains
            [M(:,:,k)] = log(P); % log(sum image)
        end

    case 'iso' % my iso measure
        numDims = numel([Rmax Rmax]);
        idx   = cell(1,numDims); sizeB = zeros(1,numDims);
        for k = 1:numDims
            M = size(X,k);
            idx{k} = (1:M) + Rmax;
            sizeB(k) = M + 2*Rmax;
        end
        xp = repmat(feval(class(X), 0), sizeB); xp(idx{:}) = X;
        MAX = sensibility;
        del = [1/MAX 3/MAX 5/MAX 7/MAX 9/MAX 11/MAX 13/MAX 15/MAX 17/MAX];
        [M(:,:,1)] = 0;
        for k = 2:brojciklusa
            for i = 1:m
                ii = i+Rmax;
                for j = 1:n
                    jj = j + Rmax;
                    IS  = length(find(abs(xp(ii-k+1:ii+k-1,jj-k+1:jj+k-1)-xp(ii,jj)) <= del(k)));
                    % IS - number of repeated pixels in measure domain
                    M(i,j,k) = log(IS);
                end
            end
        end
end

LogRegDim(1:brojciklusa) = LogDim(1:brojciklusa);
if(Rmax >= 1)
    % alpha image A(i,j)calculation
    for i=1:m
        for j=1:n
            pom = my_polyfit(LogRegDim,M(i,j,1:brojciklusa));
            % alpha value calculation from linear regression, speeded up version
            A(i,j)= pom(1);
        end
    end
else
    % to avoid negative alpha values in case where only one pixel domain was used
    % M < 0, because 0 < X < 1 and M = log(X)
    A = -M(:,:,1);
end

%to avoid negative alpha values for minimum measure
if Rmax >= 1 && (strcmp(method{1},'min') || strcmp(method{1},'mini')), A = -A; end
%neglecting too small values
A(abs(A) < 0.0001) = 0;

end

%--------------------------------------------------------------------------
function p = my_polyfit(x,y)
% Polynomial fitting, standard MatLab function accelerated by avoiding all unnecesary lines

x = x(:); y = y(:);

% Construct Vandermonde matrix.
V(:,1) = x; V(:,2) = ones(length(x),1);

% Solve least squares problem, and save the Cholesky factor.
[Q,R] = qr(V,0);
p = R\(Q'*y);    % Same as p = V\y;
p = p.';         % Polynomial coefficients are row vectors by convention.
end

%--------------------------------------------------------------------------
function B = my_ordfilt2(A,order,domain)
% ordfilt2 MatLab function accelerated by avoiding all unnecesary lines

domainSize = size(domain);
center = floor((domainSize + 1) / 2);
[r,c] = find(domain);
r = r - center(1); c = c - center(2);
padSize = max(max(abs(r)), max(abs(c)));
padSize = padSize * [1 1];
originalSize = size(A);

numDims = numel(padSize);
% Form index vectors to subsasgn input array into output array.
% Also compute the size of the output array.
idx   = cell(1,numDims);
for k = 1:numDims
    M = size(A,k);
    dimNums = [1:M M:-1:1];
    p = padSize(k);
    idx{k}   = dimNums(mod(-p:M+p-1, 2*M) + 1);
end
A = A(idx{:});

Ma = size(A,1);
offsets = c*Ma + r;

B = ordf(A, order, offsets, [padSize(1) padSize(2)] + 1, originalSize, domainSize);

end

%--------------------------------------------------------------------------
function b = my_colfilt(a,nhood)
% colfilt MatLab function accelerated by avoiding all unnecesary lines

[ma,na] = size(a);

k=100; % Default block size
% Define acceptable block sizes
m = floor(k):-1:floor(min(ceil(ma/10),ceil(k/2)));
n = floor(k):-1:floor(min(ceil(na/10),ceil(k/2)));
% Choose that largest acceptable block that has the minimum padding.
[dum,ndx] = min(ceil(ma./m).*m-ma); blk(1) = m(ndx);
[dum,ndx] = min(ceil(na./n).*n-na); blk(2) = n(ndx);
block = blk;

% Process the matrix in blocks of size BLOCK.
% Expand A: Add border, pad if size(a) is not divisible by block.
mpad = rem(ma,block(1)); if mpad>0, mpad = block(1)-mpad; end
npad = rem(na,block(2)); if npad>0, npad = block(2)-npad; end
aa = repmat(feval(class(a), 0), size(a) + [mpad npad] + (nhood-1));
aa(floor((nhood(1)-1)/2)+(1:ma),floor((nhood(2)-1)/2)+(1:na)) = a;

m = block(1) + nhood(1)-1;
n = block(2) + nhood(2)-1;
mblocks = (ma+mpad)/block(1);
nblocks = (na+npad)/block(2);

% Figure out return type
chunk = a(1:nhood(1), 1:nhood(2));
temp = sum(chunk(:));
b = repmat(feval(class(temp), 0), [ma+mpad,na+npad]);
arows = (1:m); acols = (1:n);
brows = (1:block(1)); bcols = (1:block(2));
mb = block(1); nb = block(2);

for i=0:mblocks-1,
    for j=0:nblocks-1,
        x = my_im2col(aa(i*mb+arows,j*nb+acols),nhood);
        b(i*mb+brows,j*nb+bcols) = reshape(sum(x),block(1),block(2));
    end
end
b = b(1:ma,1:na);
end

%--------------------------------------------------------------------------
function b = my_im2col(a,block)
% im2col MatLab function accelerated by avoiding all unnecesary lines

[ma,na] = size(a);
m = block(1); n = block(2);

if any([ma na] < [m n]) % if neighborhood is larger than image
    b = zeros(m*n,0);
    return
end

% Create Hankel-like indexing sub matrix.
mc = block(1); nc = ma-m+1; nn = na-n+1;
cidx = (0:mc-1)'; ridx = 1:nc;
t = cidx(:,ones(nc,1)) + ridx(ones(mc,1),:);    % Hankel Subscripts
tt = zeros(mc*n,nc);
rows = 1:mc;

for i=0:n-1,
    tt(i*mc+rows,:) = t+ma*i;
end
ttt = zeros(mc*n,nc*nn);
cols = 1:nc;

for j=0:nn-1,
    ttt(:,j*nc+cols) = tt+ma*j;
end

b = a(ttt);

end

%--------------------------------------------------------------------------
function [Domain] = domeni
% Function domeni predefined diamond shaped measure domains of different sizes

Domain(1).dom = [   0   1   0
                    1   1   1
                    0   1   0    ];
                
Domain(2).dom = [   0     0     1     0     0
                    0     1     1     1     0
                    1     1     1     1     1
                    0     1     1     1     0
                    0     0     1     0     0   ];

Domain(3).dom = [   0     0     0     1     0     0     0
                    0     0     1     1     1     0     0
                    0     1     1     1     1     1     0
                    1     1     1     1     1     1     1
                    0     1     1     1     1     1     0
                    0     0     1     1     1     0     0
                    0     0     0     1     0     0     0   ];

                    
Domain(4).dom = [       0     0     0     0     1     0     0     0     0
                        0     0     0     1     1     1     0     0     0
                        0     0     1     1     1     1     1     0     0
                        0     1     1     1     1     1     1     1     0
                        1     1     1     1     1     1     1     1     1
                        0     1     1     1     1     1     1     1     0
                        0     0     1     1     1     1     1     0     0
                        0     0     0     1     1     1     0     0     0
                        0     0     0     0     1     0     0     0     0 ];

Domain(5).dom = [  0     0     0     0     0     1     0     0     0     0     0
                   0     0     0     0     1     1     1     0     0     0     0
                   0     0     0     1     1     1     1     1     0     0     0
                   0     0     1     1     1     1     1     1     1     0     0
                   0     1     1     1     1     1     1     1     1     1     0
                   1     1     1     1     1     1     1     1     1     1     1
                   0     1     1     1     1     1     1     1     1     1     0
                   0     0     1     1     1     1     1     1     1     0     0
                   0     0     0     1     1     1     1     1     0     0     0
                   0     0     0     0     1     1     1     0     0     0     0
                   0     0     0     0     0     1     0     0     0     0     0 ];
end