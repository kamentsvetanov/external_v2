function [P,PC,PCB,depth,front] = percolation(mat,varargin)
%Simulates an Invasion Percolation.
%
%   [P,PC,PCB] = percolation(MAT) Simulates an invasion percolation in a input
%   material, MAT and it returns the percolation cluster surperimposed on
%   the given material, PER. The function also returns the percolation cluster
%   alone, PC and the binary version of the percolation cluster, PCB. 
%   The parameter MAT is a real matrix.
%
%   [P,PC,PCB] = percolation(...,'iter',NI) Returns P, PC and PCB using a
%   specified number of iterations, NI. The parameter NI is a positive integer.
%   If ITER is not specfied, the default value is NI = 1000.
%
%   [P,PC,PCB] = percolation(...,'OPTION') Perform the simulation with a
%   specific visualization option. The possible options that can be applied
%   are 'visu' in order to show the progression of the percolation or 'novisu'
%   in order not to show the progression.
%   If VISUS is not specified, the default value is VISUS = VISU.
%
%   [...,depth,front] = percolation (...) Returns the depth of the
%   percolation cluster, DEPTH, and the length of the percolation cluster
%   front, FRONT, both as a function of time.
%
%   Example
%
%       % Simulation of an invasion percolation
%       I = rand(128,128);
%       [P,PC,PCB,depth,front] = percolation(I);
%
% Reference page in Help browser
%     <a href="matlab:fl_doc percolation ">percolation</a>

% Modified by Christian Choque Cortez, November 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(1,4);
nargoutchk(3,5);

if ~isnumeric(mat) || isvector(mat), error('The material input must be a numerical matrix');end
if nargin > 1
    arguments = varargin;
    list1 = {'visu','novisu'}; 
    
    [visus, arguments] = checkforargument(arguments,list1,'visu');
    [ni,arguments] = checkforargument(arguments,'iter',1000);
    if ~isnumeric(ni) || (ni - floor(ni)), error('Invalid use of iter property'); end %#ok<BDLOG>
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    ni = 1000;
    visus = {'visu'};
end

%--------------------------------------------------------------------------
% The material is rescaled between 0 and 1.
Pmat = (mat-min(min(mat)))/(max(max(mat))-min(min(mat)));
n = min(size(Pmat));

% Initialisation: All points are dry at the beginning.
PC = zeros(n,n); PCB = zeros(n,n);

F = ones(n,n); % No point is accessible.
F(1,:) = Pmat(1,:); % At time 1, the first line of the material is accessible.
P = Pmat/2; % A is used to "superimpose" the percolation cluster on the material.

depth = zeros(1,ni); % current depth of the percolation cluster.
front = zeros(1,ni); % current length of the percolation front.

if strcmp(visus,'novisu')
    h_waitbar = fl_waitbar('init');
else
    index_fig1 = figure;
    set(index_fig1,'DoubleBuffer','on')
    subplot(2,2,1); imagesc(P);
    subplot(2,2,2); imagesc(PCB);
    subplot(2,2,3); image(PC);
    subplot(2,2,4); imagesc(F);
end


% Loop on time instants
for i=1:ni
    [fmin1,floc1] = min(F); % Localize the min of F.
    [fmin2,floc2] = min(min(F));
    
    % The minimum de F is at (floc1(flco2),floc2). This location is wetted in PC
    PC(floc1(floc2),floc2) = Pmat(floc1(floc2),floc2);
    PCB(floc1(floc2),floc2) = 1;
    P(floc1(floc2),floc2) = 1;
    
    % The point must be withdrawn from F, i.e. put at 1, so that it is not considered "wettable" anymore
    F(floc1(floc2),floc2) = 1;

    % Verify if the percolation is over
    if floc1(floc2)==n, break; end
    
    % The new wettable points are put in F:
    % Those in contact with the one just wetted. Percolation downwards provided the point is not already wet.
    if PCB(floc1(floc2)+1,floc2) == 0
        F(floc1(floc2)+1,floc2) = Pmat(floc1(floc2)+1,floc2);
    end
    
    % Percolation leftwards provided the point is not already wet and one is not on the left side of the media.
    if floc2 >1 && PCB(floc1(floc2)+1,floc2-1) == 0
        F(floc1(floc2)+1,floc2-1) = Pmat(floc1(floc2)+1,floc2-1);
    end
    
    % Percolation rightwards provided the point is not already wet and one is not on the right side of the media.
    if floc2 <n && PCB(floc1(floc2)+1,floc2+1) == 0
        F(floc1(floc2)+1,floc2+1) = Pmat(floc1(floc2)+1,floc2+1);
    end

    depth(i) = max(depth(max(i-1,1)),floc1(floc2)); % update the depth
    front(i)=sum(sum((1-F)>0)); % update the length

    %Display the growth of PC
    if strcmp(visus,'novisu')
        fl_waitbar('view',h_waitbar,i,ni);
    else
        subplot(2,2,1); imagesc(P); title('Percolation superimposed');
        subplot(2,2,2); imagesc(PCB); title('Percolation cluster (binary)');
        subplot(2,2,3); imagesc(PC); title('Percolation cluster');
        subplot(2,2,4); imagesc(F); title('Percolation front');
        getframe;
    end
end

if strcmp(visus,'novisu')
    index_fig1 = figure;
    fl_waitbar('close',h_waitbar);
end

figure(index_fig1);
subplot(2,2,1); imagesc(P); title('Percolation superimposed');
subplot(2,2,2); imagesc(PCB); title('Percolation cluster (binary)');
subplot(2,2,3); imagesc(PC); title('Percolation cluster');
subplot(2,2,4); imagesc(F); title('Percolation front');

if nargout > 3
    figure;
    subplot(2,1,1); plot(depth(1:i-1));
    title('Depth of the percolation cluster as a function of time')
    subplot(2,1,2); plot(front(1:i-1));
    title('Length of the percolation cluster front as a function of time')
end

end