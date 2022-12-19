% Estimation of the Hölder function H of an MBM with the Increments Ratio 
% (IR) statistic.
% Author : J.M. Bardet, adapted for FracLab by J. Lévy Véhel 
% Input:    sig, signal to be analyzed.
%           winsize, size of neighbourhood for estimating the IR.
%           The actual size is $n^{1-winsize}$. Default : 0.35
% Output:   HIR=vector of IR estimations (the Hölder function)
% 
% Reference : J.M. Bardet, D. Surgailis, 
% "Nonparametric estimation of the local Hurst function of multifractional 
% Gaussian processes", SPA, to appear.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [HIR]=flVariaIR(sig,winsize)
n=length(sig);

M=5;
nbt=200;

Hest2=0;
R2=0;
HIR=0;


% Estimation of the function H for a window of length $n^{1-alpha}$

alpha=winsize; % Choice of the local window of length $n^{1-alpha}$

mfBm=sig;
mfGn=mfBm(2:n)'-mfBm(1:(n-1))';
S=0;

    
    q=0;
    for t=fix((2+n^(1-alpha))):fix((n/nbt)):(n-2*M-fix(n^(1-alpha)))
        q=q+1;
        pdep=fix(t-n^(1-alpha));
        pfin=fix(t+n^(1-alpha));
        
        for m=1:M
            p=pdep:m:pfin;
            S(m)=mean((mfBm(2*m+p)-2*mfBm(m+p)+mfBm(p)).^2);
            A(m)=log(m)-mean(log(1:M));
        end
        
        p=pdep:pfin;
        R2(q)=mean(abs(mfGn(3+p)-mfGn(1+p))./(abs(mfGn(3+p)-mfGn(2+p))+abs(mfGn(2+p)-mfGn(1+p))));
        Hest2(q)=HestIR(R2(q),2); % Computation of the IR estimator
    end

    indt=0;
    for t=fix((2+n^(1-alpha))):fix((n/nbt)):(n-2*M-fix(n^(1-alpha)))
        indt=indt+1;
        HIR(indt)=mean(Hest2(indt));
        VIR(indt)=std(Hest2(indt));
    end
    
%     figure
%     indx=((1+n^(1-alpha)):(n/nbt):(n-2*M-fix(n^(1-alpha))))/n;
%     longx=length(indx);
%     plot(indx,HIR(1:longx))
%     xlabel('time')
%     ylabel('H')
%     title(alpha)
%     


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Computation of the IR estimator
%
% Input : R=IR statistic
%         p=1 or 2 order of the IR statistic
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function HDon=HestIR(R,p)

H=0.0001:0.0001:0.9999;
if p==1
    r=2.^(2*H-1)-1;
end
if p==2
    r=(-3.^(2*H)+2.^(2*H+2)-7)./(8-2.^(2*H+1));
end
Lambda=1/pi*acos(-r)+sqrt(1-r.^2)./(pi*(1-r)).*log(2./(r+1));
HDon=sum(R>Lambda)/10000;

