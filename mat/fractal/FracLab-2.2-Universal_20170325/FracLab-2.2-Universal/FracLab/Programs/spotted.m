function [Yh,catSe] = spotted(X,F,varargin)
% SPOTTED Computes the black and white segmentation of the f(alpha) image
%         and performs the Small Objects Detection over the original image.
%
%   [Yh catSe] = spotted(X,F) Estimates the black and white segmentation, Yh, of
%   the f(alpha) image, F, and estimates the Haussdorf segmentation, catSe,
%   in order to perform the small object detection over the input image, X.
%
%   [Yh,catSe] = spotted(...,[MIN,MAX]) Estimates Yh and catSe within the interval (MIN:MAX).
%   The parameters MIN and MAX are positive reals in (0:2). The couple [MIN,MAX] sets the 
%   range of values of f(alpha) that defines the segmentation, i.e. points in the original
%   image with alpha such that f(alpha) belongs to [min,max] are kept in the segmented image.
%   If the couple [MIN,MAX] is not specified, the default value is [MIN,MAX] = [0,0.25]. 
%
%   Example
%
%       images_loc = which('alphaimage.html');
%       x = imread(fullfile(fileparts(images_loc),'images_examples','Segmentation','m213.pgm'));
%       x = ima2mat(x);
%       A = alphaimage(x,2,'neg'); F = falphaimage(A,100);
%       [F_bw,F_seg] = spotted(x,F);
%       figure; subplot(1,2,1); imagesc(F_bw); title('Black and white segmentation');
%       subplot(1,2,2); imagesc(F_seg); title('Haussdorf segmentation');
%
%   See also alphaimage, falphaimage
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
%     <a href="matlab:fl_doc spotted ">spotted</a>

% Author Tomislav Stojic, Irini Reljin, Branimir Reljin, University of Belgrade-Serbia, July 2004
% Modified by Christian Choque Cortez, September 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(2,3)
nargoutchk(1,2)

vect = [0,0.25];
if nargin == 3
    vect = varargin{1};
    if size(vect,1) ~=1 && size(vect,1) ~=2, error('Invalid [MIN,MAX] input'); end
    if ~isnumeric(vect), error('Invalid [MIN,MAX] input'); end
    if vect(1) > vect(2), error('Invalid [MIN,MAX] input'); end
    if vect(1) < 0 || vect(2) > 2, error('Invalid [MIN,MAX] input'); end
end

%--------------------------------------------------------------------------
Xa = double(X)/double(max(X(:)));
[m,n] = size(Xa);
Xa = (Xa-min(Xa(:)))./(1-min(Xa(:)));
rect = [0 0 0 0];
donjif = vect(1); gornjif = vect(2);

% Black and white segmentation for given  f(alpha) range
Yh = zeros(m,n);
XN = Xa; Se = Xa;
[xc yc] = find((F > donjif) & (F <= gornjif));
xoc = xc + floor(rect(2)); yoc = yc + floor(rect(1));
d = (yoc -1) * m + xoc;
Yh(d)=1;

% Basic morphological postprocessing of bw segmented image
Yhclose = fl_close_D(Yh); Yhopen = fl_open_D(Yhclose);
Se(my_bwmorph(Yhopen)) = 1; XN(my_bwmorph(Yhopen)) = 0;

catSe = cat(3,Se,XN,XN);
end

%--------------------------------------------------------------------------
function img = fl_open_D(img)

img = fl_dilate_D(fl_erode_D(img));
end

%--------------------------------------------------------------------------
function img = fl_close_D(img)

img = fl_erode_D(fl_dilate_D(img));
end

%--------------------------------------------------------------------------
function img_erodee = fl_erode_D(img)

n = size(img,1); m = size(img,2);
up = [2:n,n]; down = [1,1:n-1];
right = [2:m,m]; left = [1,1:m-1];
img_erodee = (img&img(up,:)&img(down,:)&img(:,left)&img(:,right));
end

%--------------------------------------------------------------------------
function img_dilatee = fl_dilate_D(img)

n = size(img,1); m = size(img,2);
up = [2:n,n]; down=[1,1:n-1];
right = [2:m,m]; left = [1,1:m-1];
img_dilatee = (img|img(up,:)|img(down,:)|img(:,left)|img(:,right));
end

%--------------------------------------------------------------------------
function cout = my_bwmorph(a)
% bwmorph MatLab function accelerated by avoiding all unnecesary lines

n= 1;
c = a; iter = 1; done = n == 0;

while (~done)
    lastc = c;
    c = applylutc(c,lutper4);
    done = ((iter >= n) | isequal(lastc, c));
    iter = iter + 1;
end

cout = c;
end

%--------------------------------------------------------------------------
function lut = lutper4
%LUTPER4 Compute "perim4" look-up table.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.10.4.2 $  $Date: 2003/08/23 05:54:04 $

lut = [ ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     0     0     0     0     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     0     0     0     0 ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     1     1     1     1     0     0     0     0     0     0     0     0 ...
     0     0     0     0     0     0     0     0     1     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     0     0     0     0     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     0     0     0     0 ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     1     1     1     1     0     0     0     0     0     0     0     0 ...
     0     0     0     0     0     0     0     0     1     1     1     1 ...
     1     1     1     1     1     1     0     0     1     1     0     0 ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     0     0     0     0     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     0     0     0     0 ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     1     1     1     1     1     1     1     1     1     1     0     0 ...
     1     1     0     0     0     0     0     0     0     0     0     0 ...
     0     0     0     0     0     0     0     0     1     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     0     0     0     0     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     0     0     0     0 ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     1     1     1     1     0     0     0     0     0     0     0     0 ...
     0     0     0     0     0     0     0     0     1     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     0     0     0     0     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     0     0     0     0 ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     1     1     1     1     1     1     1     1     1     1     0     0 ...
     1     1     0     0     0     0     0     0     0     0     0     0 ...
     0     0     0     0     0     0     0     0     1     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     0     0     0     0     1     1     1     1     1     1     1     1 ...
     1     1     0     0     1     1     0     0];

lut = lut(:);
end
