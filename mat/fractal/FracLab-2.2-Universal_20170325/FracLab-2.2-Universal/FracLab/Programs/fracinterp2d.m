function xi = fracinterp2d(x,ninterp,varargin)
% FRACINTERP2D Computes the interpolation of a 2D signal
%
%   XI = FRACINTERP2D(X,NI) Computes the interpolated signal, XI, of the input signal,
%   X, using a specific number of interpolation, NI and a Triangle biorthonormal
%   quadrature mirror filter. Beware, if the number of interpolations NI > 3 the
%   process will take a long time.
%
%   XI = FRACINTERP2D(...,'levels',[START,END]) Computes XI with specific start level
%   and end level values. The parameters START and END are positive integers that
%   specify the minimum and maximum scales which are used to compute the interpolation.
%   The START value must be at least equal to 2 and the END level must be lower
%   than log2 of the length input signal.
%   If LEVELS is not specified, the default vector is [START,END] = [2,log2(length(X))].
%
%   Example
%
%       images_loc = which('fracinterp2d.html');
%       x = imread(fullfile(fileparts(images_loc),'images_examples','Interpolation','door.tif'));
%       x = ima2mat(x);
%       y = fracinterp2d(x,1,'levels',[2,8]);
%       figure; subplot(1,2,1); imagesc(x); title('Input image');
%       subplot(1,2,2); imagesc(y); title('Interpolated image');
%       colormap(gray);
%
% Reference page in Help browser
%     <a href="matlab:fl_doc fracinterp2d ">fracinterp2d</a>

% Author: Pierrick Legrand 2003
% Modified by Christian Choque Cortez, May 2010
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
narginchk(2,6);
nargoutchk(1,1);

[N1,N2] = size(x); N = min(N1,N2);
if nargin > 2
    arguments = varargin;
    list_filter1 = {'daubechies','coiflet'};
    list_filter2 = {'Triangle'};
    
    [filterparam, arguments] = checkforargument(arguments,list_filter1,'Triangle','wo');
    if strcmp(filterparam{1},'Triangle')
        [filterparam, arguments] = checkforargument(arguments,list_filter2,'Triangle');
    end
    [level, arguments] = checkforargument(arguments,'levels',[2,floor(log2(N))]);
    if ~isnumeric(level), error('Invalid use of level property'); end
    if norm(level) ~= 0 && (length(level(1,:)) ~= 2 || length(level(:,1)) ~= 1)
        error('level input argument must be a [x,y] vector');
    end
    lmin = level(1); lmax = level(2);
    if lmin < 2, error('Start level input argument must be higher than 2'); end
    if lmax > floor(log2(N)), error('End level input argument is out of range'); end
    if (strcmp(filterparam{1},'daubechies') || strcmp(filterparam{1},'coiflet')) && length(filterparam) ~= 2,
        error('Invalid use of filterparam property'); end
    if (strcmp(filterparam{1},'daubechies') || strcmp(filterparam{1},'coiflet')) && (~isscalar(filterparam{2}) || filterparam{2} <= 0),
        error('The wave order must be a positive integer'); end
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    filterparam = {'Triangle'};
    lmin = 2; lmax = floor(log2(N));
end

%--------------------------------------------------------------------------
if strcmp(filterparam{1},'Triangle'),
    wave_order = 0;
else
    wave_order = filterparam{2};
end
h = fl_waitbar('init');

for ni = 1:ninterp
    [N1,N2] = size(x);
    croix1 = zeros(2*N1,2*N2);

    if ~wave_order
        for i = 1:N1
            fl_waitbar('view',h,i,N1+N2);
            [ligne,nowaitbar] = fracinterp1d(x(i,1:N2),1,'levels',[lmin,lmax]); %#ok<NASGU>
            croix1(2*i-1,:) = ligne;
        end

        for i = 1:N2
            fl_waitbar('view',h,i+N1,N1+N2);
            [colonne,nowaitbar] = fracinterp1d(x(1:N1,i),1,'levels',[lmin,lmax]); %#ok<NASGU>
            croix1(:,2*i-1) = colonne;
        end
    else
        for i = 1:N1
            fl_waitbar('view',h,i,N1+N2);
            [ligne,nowaitbar] = fracinterp1d(x(i,1:N2),1,'levels',[lmin,lmax],filterparam{1},wave_order); %#ok<NASGU>
            croix1(2*i-1,:) = ligne;
        end

        for i = 1:N2
            fl_waitbar('view',h,i+N1,N1+N2);
            [colonne,nowaitbar] = fracinterp1d(x(1:N1,i),1,'levels',[lmin,lmax],filterparam{1},wave_order); %#ok<NASGU>
            croix1(:,2*i-1) = colonne;
        end
    end

    for i = 1:N1-1
        for j = 1:N2-1
            croix1(2*i,2*j) = (croix1(2*i-1,2*j-1) + croix1(2*i-1,2*j) + ...
                croix1(2*i-1,2*j+1) + croix1(2*i,2*j-1) + croix1(2*i,2*j+1) + ...
                croix1(2*i+1,2*j-1) + croix1(2*i+1,2*j) + croix1(2*i+1,2*j+1))/8;
        end
    end

    for j = 1:N2-1
        croix1(2*N1,2*j) = (croix1(2*N1-1,2*j-1) + croix1(2*N1-1,2*j) + ...
            croix1(2*N1-1,2*j+1) + croix1(2*N1,2*j-1) + croix1(2*N1,2*j+1))/5;
    end

    for i=1:N1-1
        croix1(2*i,2*N2) = (croix1(2*i-1,2*N2-1) + croix1(2*i-1,2*N2) + ...
            croix1(2*i,2*N2-1) + croix1(2*i+1,2*N2-1) + croix1(2*i+1,2*N2))/5;
    end

    croix1(2*N1,2*N2) = (croix1(2*N1-1,2*N2-1) + croix1(2*N1-1,2*N2) + croix1(2*N1,2*N2-1))/3;

    xi = croix1;
    x = xi;
end

fl_waitbar('close',h);
end