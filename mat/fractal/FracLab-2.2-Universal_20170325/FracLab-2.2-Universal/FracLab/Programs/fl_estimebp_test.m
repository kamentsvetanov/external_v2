function [L,levels]=fl_estimebp_test(X,delta,mMlevels)
%Compute the optimum interval of levels and test for Get hits parameter

% Author W. Arroum, December 2005

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

L=1;
levels=[];
if isempty(delta)
    delta=std(diff(X));
end



half=max(abs(max(X-X(1))),abs(min(X-X(1))));
if half/delta<1
    fl_error('Value of Delta too big');
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
    if delta<=std(diff(X))
        fl_error('These data have not enough levels of crossings. The computation cannot be done. Please use a vector with more observation.');
        L=0;
        return
    else
        fl_error('These data have not enough levels of crossings. The computation cannot be done. Please use a vector with more observation or reduce the value of Delta.');
        L=0;
        return
    end
end

if (~isempty(mMlevels))
    if maxlevel>= mMlevels(2)
       maxlevel=mMlevels(2);
    else
       fl_warning(['Levels biger than ''' num2str(maxlevel) ''' are not take into consideration. No crossing at that levels. Max level set at ''' num2str(maxlevel) '''']...
           ,'blue');
    end
    if minlevel > mMlevels(1)
       fl_warning(['Levels smaller than ''' num2str(minlevel) ''' have no sens for the Hurst estimation. Min level set at ''' num2str(minlevel) '''']...
           ,'blue');
    else
        minlevel=mMlevels(1);
    end
end
levels=[minlevel;maxlevel];

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