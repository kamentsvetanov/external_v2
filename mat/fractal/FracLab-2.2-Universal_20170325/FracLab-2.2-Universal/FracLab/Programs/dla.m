function [A,rnp,pnp] = dla(N,varargin)
% DLA Simulates a Diffusion Limited Agregation.
%
%   A = DLA(N) Simulates a diffusion limited agregation, A, using a matrix
%   size N. The parameter N is positive integer that defines the size of the
%   matrix containing the cluster.
%
%   A = DLA(...,'radius',[RL,RK]) Simulates A using specific circle radius,
%   [RL, RK]. The parameter RL and RK are positive reals that respectly define
%   the launching radius from where the particles are launched and the killing
%   radius where the particles are annihilated if they reach it.
%   If RADIUS are not specified, the default values are [RL,RK] = [1,20].
%
%   A = DLA(...,'parts',NP) Simulates A using a specific number of particles, NP.
%   The parameter NP is a positive integers that defines the maximum number
%   of particles for the simulation.
%   If PARTS is not specified, the default value is NP = 10000.
%
%   A = DLA(...,'moves',NM) Simulates A using a specific number of movements, NM.
%   The parameter NM is a positive integer that defines the maximum number of
%   moves allowed to the particles.
%   If MOVES is not specified, the default value is NM = 2000.
%
%   A = DLA(...,'stick',SP) Simulates A using a specific sticking probability, SP.
%   The parameter SP is a positive real in (0,1).
%   If STICK is not specified, the default value is SP = 1.
%
%   A = DLA(...,'VISUALIZATION') Simulates A using a specific visualization. 
%   The possible VISUALIZATION options that can be applied are 'visup' in order
%   to visualize each agregated particle, 'visud' in order to visualize the 
%   diffusion of each particle or 'novisu' in order to not show any visualization.
%   If VISUALIZATION is not specified, the default value is VISUALIZATION = VISUP.
%
%   [A,RNP,PNP] = (...) Simulates A and computes the radius of the cluster, RNP,
%   and the number of particles in the cluster, PNP, as a function of the number
%   of launched particles.
%
%   Example
%
%       % Simulation of a diffusion limited agrgation
%       N = 256; rl = 1; rk = 20; np = 10000; nm = 2000;
%       x = dla(N,'radius',[rl,rk],'parts',np,'moves',nm);
%
% Reference page in Help browser
%     <a href="matlab:fl_doc dla ">dla</a>

% Modified by Christian Choque Cortez, November 2009
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

narginchk(1,10);
nargoutchk(1,3);

if nargin > 1
    arguments = varargin;
    list1 = {'visup','visud','novisu'}; 
    
    [visu, arguments] = checkforargument(arguments,list1,'visup');
    [rads, arguments] = checkforargument(arguments,'radius',[1,20]);
    if ~isnumeric(rads) || length(rads) ~= 2, error('Invalid use of radius property');
    else rl = rads(1); rk = rads(2); end
    [np,arguments] = checkforargument(arguments,'parts',10000);
    if ~isnumeric(np) || (np - floor(np)), error('Invalid use of parts property'); end %#ok<BDLOG>
    [nm, arguments] = checkforargument(arguments,'moves',2000);
    if ~isnumeric(nm) || (nm - floor(nm)), error('Invalid use of moves property'); end %#ok<BDLOG>
    [sp, arguments] = checkforargument(arguments,'stick',1);
    if ~isnumeric(sp), error('Invalid use of stick property'); end
    if ~isempty(arguments), error('Too many input arguments.'); end
else
    rl = 1; rk = 20;
    nm = 2000; np = 10000;
    sp = 1;
    visu = {'visup'};
end

%--------------------------------------------------------------------------
rci=1; %square of the initial cluster radius.
rli=3; %initial radius of the launching circle.
rki=9; %initial square of the radius of the annihilating circle.
if strcmp(visu{:},'novisu'), vis = 0;
elseif strcmp(visu{:},'visup'), vis = 1;
elseif strcmp(visu{:},'visud'), vis = 2;
end

A = zeros(N,N); %matrix containing the cluster
B = A; %matric for visualizing the moving particles
A(N/2,N/2) = 1/2; %seed of the cluster

%prepare for visualization.
if vis >= 1
    nf1 = figure; set(nf1,'DoubleBuffer','on');
    imagesc(A); title(['DLA with  ', num2str(np), ' particles']); axis image;
else
    h_waitbar = fl_waitbar('init');
end

pnp = ones(1,np); %current number of particles in the cluster
cpn = 1; %auxiliary variable for the number of particle used in the inner loop
rnp = ones(1,np); %current radius of the cluster
theta = 2*pi*rand(1,np); %draw the random angles for the starting point of the particles

%loop on the particles.
for jj = 1:np
    if vis == 0, fl_waitbar('view',h_waitbar,jj,np); end

    rdx=rand(1,nm);
    rdy=rand(1,nm);

    %initial position.
    x=N/2+floor(rli*cos(theta(jj)));
    y=N/2+floor(rli*sin(theta(jj)));

    %loop on the movement of each particle
    for dep = 1:nm

        %diffusion erase the particle from its current position (for visualization purpose)
        B(x,y) = 0;

        %computes the move
        dx = floor(3*rdx(1,dep))-1;
        dy = floor(3*rdy(1,dep))-1;
        x = max(2,min(N-1,x+dx));
        y = max(2,min(N-1,y+dy));

        %test whether the particle has reached the cluster
        %and sticks to it depending on the sticking probabilty sp
        if max(max(A(x-1:x+1,y-1:y+1)))>0 && rand<sp
            %the particle is sticked with a colour depending on the arrival time.
            cpn = cpn+1;
            A(x,y) = 1-jj/np;
            %updates the various radii.
            rci = max(rci,(x-N/2)^2+(y-N/2)^2);
            rli = sqrt(rci+rl);
            rki = (rli+rk)^2;
            if vis == 1
                imagesc(A); 
                getframe;
            end
            break
        end

        %annihilate the particle if it reaches the annihilating circle.
        if (x-N/2)^2+(y-N/2)^2 > rki
            break
        end

        %puts the particle in its new position
        B(x,y) = .6;
        if vis == 2
            imagesc(max(A,B));
            getframe;
        end
    end

    rnp(jj) = sqrt(rci);
    pnp(jj) = cpn;
    %stop the simulation if the radius of launching is too large.
    if rli > N/2-1
        break
    end
end

if vis == 0
    fl_waitbar('close',h_waitbar);
    figure; imagesc(A); axis image;
end
title(['DLA with  ', num2str(np), ' particles']);

if nargout > 1
    rnp = rnp(1:jj-1); pnp = pnp(1:jj-1);
    figure; subplot(3,1,1); plot(rnp); xlim([0 jj])
    title('Radius of the cluster as a function of the # of launched particles')
    subplot(3,1,2); plot(pnp); xlim([0 jj])
    title('# of particles in the cluster as a function of the # of launched particles')
    subplot(3,1,3); loglog(rnp,pnp); xlim([0 rnp(end)])
    title('Logarithm of the # of particles as a function of the logarithm of the radius')
end
end