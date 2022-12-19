function L = lacunarity(x,kv,varargin)
% LACUNARITY Computes the heterogeneity or lacunarity for a 2D signal (an image)
%
%   L = LACUNARITY(X,KV) Computes the lacunarity L of the image X by centering 
%   at each point of X a window and comparing the "mass" in this window to the average mass.
%   A lacunarity is computed for each size of window.  The desired different
%   sizes of windows are defined as a list by the input vector KV. 
%   Thus the output L of this code is also a vector of lacunarities.
%   If (N1,N2) are the size of the image X, then the values of KV must be 
%   included in the interval [1 : max(N1,N2)]. 
%
%   L = LACUNARITY(...,'mask',M) Computes the lacunarity, L, using a specific
%   mask, M, which defines a region where L is really computed. The mask
%   must be the same size as X.
%
%   Example:
%
%       images_loc = which('lacunarity.html');
%       x = imread(fullfile(fileparts(images_loc),'images_examples','Dimensions','cheess.png'));
%       x = ima2mat(x);
%       Lx = lacunarity(x,[1:1:75]);
%       figure; subplot(1,2,1); imagesc(x); colormap(gray);
%       xlabel('number of points'); title('2-D image: x');
%       subplot(1,2,2); plot(Lx); xlabel('Window size'); ylabel('Lacunarity');
%
% Reference page in Help browser
%     <a href="matlab:fl_doc lacunarity ">lacunarity</a>

% Author Karine Christophe and Raphael Cellard, April 2003
% Modified by John Finan, November 2008
% Modified by Christian Choque Cortez, February 2009

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if nargin < 2, error('Not enough input arguments'); end
if length(kv(1,:)) == 1, error('kv input argument must be a vector'); end
if min(kv) < 1, error('The min of kv input argument must be > 1.'); end
if max(kv) > min(size(x)), error('The max of kv input argument is out of range'); end
if nargin > 2
    arguments = varargin;
    [mask,arguments] = checkforargument(arguments,'mask',[]);    
    if ~isempty(mask) && sum(size(mask)==size(x))~=2
        error('mask input must be the same size than data input'); end
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    mask = [];
end

%--------------------------------------------------------------------------
[M,N] = size(x);
nn = length(kv);
L = zeros(nn,1);

if isempty(mask), mask = true(M,N); else mask = logical(mask); end

Mass = sum(x(mask));
Mass_mask = sum(sum(mask));
dt = eucdist2(~mask);
j = 1;

if (Mass~=0)
    h_waitbar = fl_waitbar('init');
    for i = kv
        fl_waitbar('view',h_waitbar,i,length(kv));
        index = ceil(i/2);
        Mass_i = Mass*i^2/Mass_mask;
        
        weights = dt;
        weights(weights > index) = index;
        weights = weights(index:index+M-i,index:index+N-i);
        
        mat_conv = 1/Mass_i*ones(i,i);
        mat_inter = conv2(x,mat_conv,'same') - ones(M,N);
        mat2_inter = mat_inter(index:index+M-i,index:index+N-i);
        mat3_inter = (mat2_inter.^2).*weights;
        
        SSum = sum(sum(mat3_inter));
        L(j) = SSum/sum(sum(weights));j=j+1;
    end
    fl_waitbar('close',h_waitbar);
else
    fl_warning('Uniformly black image!')
end
end