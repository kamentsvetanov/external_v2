function [hl]=osclholder(y,rmin,rmax,rho,voices, varargin)
% [hp,hpr, hpm]=oscpholder(y,rmin,rmax,rho)
% y : signal
% rmin smallest oscillation scale
% rmax greatest oscillation scale
% rho ball on which to compute the global Holder exponent.

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

N=max(length(y));

hp=zeros([1,N]);
hl=zeros([1,N]);
hll=hl;
Ns=(rmax-rmin+1);
[wsup s]=cmptsup(y,rmin, rmax, Ns);
winf=cmptinf(y,rmin, rmax, Ns);
w=wsup-winf;


% calcul de l'exposant global sur une boule ar transformee ondelette
% [w s]=cwt1D(y,0.1,0.5,64);
% for i=1:N
%  for j=1:64,
%    u=abs(w(j,max(1, i-rho):min(N, i+rho)));
%    sosc(j)=norm(u,inf);
%  end;
%  a=polyfit( log(s), log(sosc) , 1);
%  hll(i)=a(1);
%end

pas=floor((Ns-1)/(voices-1));
% calcul de l'exposant global sur une boule a l'aide de l'oscillation
for i=1:N
    clear tmposc news newosc nbnew osc sosc;
    u=abs(w(1,max(1, i-rho):min(N, i+rho)));
    sosc(1)=norm(u,inf);
    news(1)=s(1);
    nbnew=1;

    for j=2:pas:Ns,
        %u=w(j,max(1, i-j):min(N, i+j));
        u=w(j,max(1, i-rho):min(N, i+rho));

        tmposc=norm(u,inf);
        if (tmposc > sosc(nbnew)),
            nbnew = nbnew+1;
            sosc(nbnew)=tmposc;
            news(nbnew)=s(j);
        end;
    end;

    %a=polyfit( log(news), log(sosc) , 1);

    % regression range
    reg=1:nbnew;
    % to correct a bug in monolr
    if length(reg)>1;
        if length(reg)<3;
            tmpstr={'ls'};
        else
            tmpstr=varargin;
        end;
        switch tmpstr{1}
            case  'wls'
                RegWeight = varargin{2}(reg)./sum(varargin{2}(reg)) ;
                [a_hat,b_hat]=monolr(log(news(reg)),log(sosc(reg)),varargin{1},RegWeight);
            case  'linf'
                [a_hat,b_hat]=regression_elimination(log(news(reg)),log(sosc(reg)),tmpstr{:});
            case  'lsup'
                [a_hat,b_hat]=regression_elimination(log(news(reg)),log(sosc(reg)),tmpstr{:});
            otherwise
                %log(news(reg)),log(sosc(reg)),tmpstr{:}
                [a_hat,b_hat]=monolr(log(news(reg)),log(sosc(reg)),tmpstr{:});
        end
    else
        %Not enough point to compute the regression
        a_hat=NaN;
        b_hat=NaN;
    end
    hl(i)=a_hat(1);
end;
