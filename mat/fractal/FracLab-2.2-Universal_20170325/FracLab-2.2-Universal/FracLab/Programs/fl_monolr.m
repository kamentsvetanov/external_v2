function [a_hat1,b_hat1,y_hat] = fl_monolr(x,y,RegType,varargin)
% The same as monolr, but :
%  . a_hat1 and b_hat1 are just scalars (last element of a_hat and b_hat 
%    if RegParam=='pls', else first)
%  . RegParam can be 'linf' or 'lsup'. In this case, fl_monolr evaluates the
%    liminf or limsup of the slope
%  . No other output arguments  
% See also MONOLR

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if nargin<3
    RegType = 'ls';
end
u=varargin;

if strcmp(RegType,'linf') || strcmp(RegType,'lsup')
    [a_hat1,b_hat1] = regression_elimination(x,y,RegType,u{:});
else
    %%%%%%% Parce que monolr avec 'wls' déconne %%%%%%%%
    if strcmp(RegType,'wls')
        x = shiftdim(x);
        y = shiftdim(y);
        if isempty(u)
            u{1} = ones(1,length(x));
        end
        W = diag(u{1});
        X = [x,ones(length(x),1)];
        Vect = inv(X'*W*X)*X'*W*y;
        a_hat1 = Vect(1);
        b_hat1 = Vect(2);
    else
        [a_hat,b_hat] = monolr(x,y,RegType,u{:});
        if strcmp(RegType,'pls')
            a_hat1 = a_hat(end);
            b_hat1 = b_hat(end);
        else
            a_hat1 = a_hat(1);
            b_hat1 = b_hat(1);
        end
    end
end
y_hat = a_hat1*x+b_hat1;