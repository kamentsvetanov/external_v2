function [Sub,levels2,hit_T,hit_P]=get_hits_W(data,varargin)
% Syntax:
% [Sub]=get_hits_W(data)
% [Sub,levels]=get_hits_W(data)
% [Sub,levels,hit_T,hit_P]=get_hits_W(data)
% [...]=get_hits_W(data,option1,option1 parameters,...)
%
% hitting times (hit_T), points (hit_P) and subcrossings (Sub) for continuous process
% levels2 is a matrix of 2 colums :
%
%               indexSub    nth level  
%           |       1           L1      | 
%           |       2           L2      | 
% levels2 = |       .           .       | 
%           |       .           .       | 
%           |       n           Ln      | 
%
% input:
% data:  either x(t(n)) or  [t(n) x(t(n))] where t(n) and x(t(n)) are
% vectors. If t(n) is not precised then the default will be t(n)=[0:n-1]
% varargin: Option 
% Example: [Sub,hit_T,hit_P,levels]=
% Wget_hits(data,option1,option1 parameters,option2,option2 parameters,...)
%
%   options             option2 parameters
%--------------------------------------------------------------------------
%   'Plot'              'yes'/'no'(default)
%   'delta'             positive value, std(x(t(n))-x(t(n-1)))(default value)
%   'deleteFirst'       'yes'(default)/'no'
%   'isIncremental'     'yes'/'no'(default)
%   'min_max_levels'    [min level; max level]. If not precise, the program
%                       choose the best min level and max level.
%--------------------------------------------------------------------------
%
% Example1:
%   y=randn(1000,1);
%   [Sub]=get_hits_W(y,'isIncremental','yes','Plot','yes');
%
% Example2:
%   y=[0;cumsum(randn(1000,1))];
%   t=[0;cumsum(abs(randn(1000,1)))];
%   [Sub,levels,hit_T,hit_P]=get_hits_W([t y],'delta',1,'min_max_levels',[2 5]);

% Author Y. Shen December 2002
% Modified by O. D. Jones July 2003
% Modified by W. Arroum December 2005

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% Set input parameters
[delta,mMlevels,deleteFirst,isIncremental,plt]=input_test(varargin); %per default [0,1,0,1,0]

% Set input data
[t,x]=set_data(data,isIncremental);

% If Delta not given by user, then set delta as the std of the observations
% jumps
if delta == 0
    delta = std(diff(x));
end

% Compute significative interval of levels
levels=level(x,delta,mMlevels);

% Detecting hit points for each levels
l=1;
for n = levels'
    DD=delta*2^n;
    [hit_T{l},hit_P{l}]=hit_points(t,x,DD,deleteFirst);
    l=l+1;
end

% subcrossing numbers at each levels
subl=1:l-2;
for ls = subl(1:end)
    Sub{ls}=nb_subs(hit_T{ls},hit_T{ls+1});
end
levels2=[subl(:) levels(2:end)];

%plot crossing trees
if plt==1
    plot_Xing(t,x,hit_T,hit_P,[[1:l-1]' levels])
end

%==========================================================================
function [t,x]=set_data(data,isIncremental)
% This function create to vectors columns t (time) and x(observation) from
% data.
if (ischar(data) || min(size(data))>2)
    Warning('data must be a numerical vector of time series or a matrix of 2 columns where the first represent thr time and the second the time series');
    return
elseif min(size(data))==1
    x =data(:);
    lx = length(x);
    t = 0:lx-1;
elseif min(size(data))==2
    if size(data,1)==2
        t =data(1,:);
        if (min(diff(t))<0)
            Warning('First columns mut be increasing observation');
            return
        end
        x =data(2,:);
        t=t(:);
        x=x(:);
    else
        t =data(:,1);
        x =data(:,2);
    end
end
%I=find(abs(x)<=2*std(x));
%R=length(I)/length(x);
%if (R>0.9 &  isIncremental==0)
  %  warning('data seem to be incremental. the function will modify the data.');
 %   isIncremental=1;
%end
if isIncremental==1
    x = [0; cumsum(x(1:end-1))];
end

%==========================================================================
function levels=level(X,delta,mMlevels)
%Compute the optimum interval of levels


half=max(abs(max(X-X(1))),abs(min(X-X(1))));
if half/delta<1
    error('Value of Delta too big');
    L=0;
    return
else
    maxlevel=ceil(log2(half/delta)); %compute maximum size
    nb=nb_hits(X,2^maxlevel*delta,1);
    while(nb<5)
        maxlevel=maxlevel-1;
        nb=nb_hits(X,2^maxlevel*delta,1);
    end
end
if std(diff(X))/delta<=1
    minlevel=0;
else
    minlevel=ceil(log2(std(diff(X))/delta)); %compute minimum size
end
if ~(minlevel<maxlevel)
    error('These data have not enough levels of crossings. The computation cannot be done. Please use a vector with more observation.');
    L=0;
    return
end

if (~isempty(mMlevels))
    if maxlevel>= mMlevels(2)
       maxlevel=mMlevels(2);
    else
       warning(['Levels biger than ''' num2str(maxlevel) ''' are not take into consideration. No crossing at that levels. Max level set at ''' num2str(maxlevel) '''']);
    end
    if minlevel > mMlevels(1)
       warning(['Levels smaller than ''' num2str(minlevel) ''' have no sens for the Hurst estimation. Min level set at ''' num2str(minlevel) '''']);
    else
        minlevel=mMlevels(1);
    end
end
levels=[minlevel:maxlevel];
levels=levels(:);
%==========================================================================
function [delta,mMlevels,deleteFirst,isIncremental,plt]=input_test(varargin)
% This function check if the varargin inputs are well defined and set the
% output appropriate.
% If varargin is empty, 
%   delta=0 
%   mMlevels=[min_level, max_level] fixed by user otherwise empty vector
%   deleteFirst=1;
%   isIncremental=0;
%   plt=0;

% are the default values.

delta=0;
mMlevels=[];
deleteFirst=1;
isIncremental=0;
isTimeSeries=1;
plt=0;
k=length(varargin{1});
if k>0
    for j=1:2:k
        if strcmp(varargin{1}{j},'deleteFirst')
                if strcmp(varargin{1}{j+1},'yes')
                    deleteFirst=1;
                elseif strcmp(varargin{1}{j+1},'no')
                    deleteFirst=0;
                else
                    error(['Check parameter input ' num2str(j+2)]);
                    return
                end
        elseif strcmp(varargin{1}{j},'isIncremental')
                if strcmp(varargin{1}{j+1},'yes')
                    isIncremental=1;
                elseif strcmp(varargin{1}{j+1},'no')
                    isIncremental=0;
                else
                    error(['Check parameter input ' num2str(j+2)]);
                    return
                end
       elseif strcmp(varargin{1}{j},'Plot')
                if strcmp(varargin{1}{j+1},'yes')
                    plt=1;
                elseif strcmp(varargin{1}{j+1},'no')
                    plt=0;
                else
                    error(['Check parameter input ' num2str(j+2)]);
                    return
                end
        elseif strcmp(varargin{1}{j}, 'delta')
                if ~ischar(varargin{1}{j+1})
                    if varargin{1}{j+1}<=0
                        error(['Parameter input ' num2str(j+2) ' must be positive']);
                        return
                    else
                        delta= varargin{1}{j+1};
                    end
                else
                    error(['Parameter input ' num2str(j+2) ' must be a real']);
                    return
                end
        elseif strcmp(varargin{1}{j}, 'min_max_levels')
                if (~ischar(varargin{1}{j+1})|| length(varargin{1}{j+1})~=2)
                    V=varargin{1}{j+1};
                    if V(1)<0
                        error(['Parameter input ' num2str(j+2) '(1) must be positive']);
                        return
                    elseif V(2)<=0
                        error(['Parameter input ' num2str(j+2) '(2) must be strictly positive']);
                        return
                   elseif V(2)<=V(1)
                        error(['Parameter input ' num2str(j+2) '(2) must be strictly positive than ' num2str(j+2) '(1)']);
                        return
                    else
                        mMlevels= V;
                    end
                else
                    error(['Parameter input ' num2str(j+2) ' must be a a vector of length 2']);
                    return
                end
        else
                error(['Parameter input ' num2str(j+1) ' not defined']);
                return
        end
    end
end

%==========================================================================
function [nb]=nb_hits(x,delta,deleteFirst)
% Compute the number of hits possible at a given level
% This function will be used to allocate memory for the function
% hit_points outputs in order to increase the speed of this last
% input: t:vector time, x:time series, delta: size of the crossing,
% deleteFirst: either 1 or 0.
% output: nb: number of crossings for the given delta
lx = length(x);    
y = (x - x(1))/delta;
if deleteFirst
    last_hit = 0;
else
    last_hit = 1;
end
nb=0;
for i = 2:lx
    if y(i-1) ~= y(i)
        if y(i-1) < y(i)
            x_init = ceil(y(i-1));
            x_final = floor(y(i));
            step = 1;
        else
            x_init = floor(y(i-1));
            x_final = ceil(y(i));
            step = -1;
        end
        for j = x_init:step:x_final
            if j ~= last_hit
                last_hit = j;
                nb=nb+1;
            end
        end
    end
end

%==========================================================================
function [hit_time,hit_point]=hit_points(t,x,delta,deleteFirst)
% Determinate the hitting point of size delta coordinate
% (hit_time,hit_point).
% input: t:vector time, x:time series, delta: size of the crossing,
% deleteFirst: either 1 or 0.
% output: hit_time: hintting time 
% hit_point: hitting point

nbhit=nb_hits(x,delta,deleteFirst); % compute the number of hits possible
if nbhit==0 % no crossing points
   hit_time=[];
   hit_point =[];
else
    lx = length(x);    
    y = (x - x(1))/delta;
    hit_time=zeros(1,nbhit);
    hit_point=zeros(1,nbhit);
    if deleteFirst
        last_hit = 0;
    else
        last_hit = 1;
    end

    k=1;
    for i = 2:lx
        if y(i-1) ~= y(i)
            if y(i-1) < y(i)
                x_init = ceil(y(i-1));
                x_final = floor(y(i));
                step = 1;
            else
                x_init = floor(y(i-1));
                x_final = ceil(y(i));
                step = -1;
            end
            for j = x_init:step:x_final
                if j ~= last_hit
                  %  hit_time(k)= t(i);
                    hit_time(k) = t(i-1) + (j - y(i-1))/(y(i) - y(i-1))*(t(i) - t(i-1));
                    hit_point(k) = j*delta + x(1);
                    last_hit = j;
                    k=k+1;
                end
            end
        end
    end
end

%==========================================================================
function S=nb_subs(hitT0,hitT1);
% This function gives the number of subcrossings for a given level n
% Input:
% hitT0: crossing time at level n-1
% hitT1: crossing time at level n
% Output:
% S: number of subcrossings at level n

n=length(hitT1);
S=zeros(1,n-1); % The length of S is n-1 we do not concider the subcrossing 
                % of the last hitting points of the nth level
    if ~isempty(hitT1)
        j0 = 1;
        while hitT0(j0) ~= hitT1(1), j0 = j0 + 1; end
        for i = 2:n
            j1 = j0 + 1;
            while hitT0(j1) ~= hitT1(i), j1 = j1 + 1; end
            S(i-1)= j1 - j0;
            j0 = j1;
        end
    end
    
%==========================================================================
function plot_Xing(t,x,T,P,levels)
% plot the observation and the crossing tree.
clf
Isub=levels(:,1);
lev=levels(:,2);


ax(1) = subplot(2,1,1);
hold on;
plot(t, x, 'g','Parent',ax(1));
title('sample path and crossings')
for n = Isub'
    if ~isempty(T{n})
        plot(T{n},P{n},'.-','Parent',ax(1))
    end
end
hold off;

ax(2) = subplot(2,1,2);
hold on;
title('crossing tree (points give start of crossing)')
ylabel('crossing size')

for n = Isub'
    if ~isempty(T{n})
        if ~isempty(T{n}(1:end-1))
            plot(T{n}(1:end-1), 2^lev(n), 'b.','Parent',ax(2));
        end
        if n ~= Isub(1)
            for i = 1:length(T{n})-1
                %if i==length(T{n})
                 %   jj  = find(T{n-1}(:) >= T{n}(i));
                %else
                    jj  = find((T{n-1}(:) >= T{n}(i)) & (T{n-1}(:) < T{n}(i+1)));
                %end
                for j = jj'
                    plot([T{n}(i), T{n-1}(j)], [2^lev(n), 2^lev(n-1)], 'b','Parent',ax(2));
                end
            end
        end
    end
end

hold off;
linkaxes(ax,'x');