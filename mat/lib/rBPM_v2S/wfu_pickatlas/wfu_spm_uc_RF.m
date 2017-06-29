function [u] = wfu_spm_uc_RF(a,df,STAT,R,n)
% corrected critical height threshold at a specified significance level
% FORMAT [u] = wfu_spm_uc_RF(a,df,STAT,R,n)
% a     - critical probability - {alpha}
% df    - [df{interest} df{residuals}]
% STAT  - Statisical feild
%		'Z' - Gaussian feild
%		'T' - T - feild
%		'X' - Chi squared feild
%		'F' - F - feild
%               'C' - Correlation field
% R     - RESEL Count {defining search volume}
% n     - number of conjoint SPMs
%
% u     - critical height {corrected}
%
%___________________________________________________________________________
%
% spm_uc returns the corrected critical threshold at a specified significance
% level (a). If n > 1 a conjunction the probability over the n values of the 
% statistic is returned.
%___________________________________________________________________________
% @(#)spm_uc_RF.m	2.4 Karl Friston 01/06/23

%___________________________________________________________________________
% 
% Note: The approximate value for the homologous correlation field 
%       is now calculated based on the (approximate) uncorrected
%       threshold, as done in other types of random field.
%
% Aug. 30, 2006.      Satoru Hayasaka
%___________________________________________________________________________

spmversion = wfu_get_ver;
% find approximate value
%---------------------------------------------------------------------------
if STAT == 'C'
    u     = C_u(a/sum(R),df);
else
    if strcmp(spmversion,'SPM8')
        u  = spm_u((a/max(R))^(1/n),df,STAT);
    else
        u     = spm_u((a/sum(R))^(1/n),df,STAT);
    end
    
end
du    = 1e-6;

% approximate estimate using E{m}
%---------------------------------------------------------------------------
d     = 1;
while abs(d) > 1e-6
	[P P p] = spm_P_RF(1,0,u,df,STAT,R,n);
	[P P q] = spm_P_RF(1,0,u + du,df,STAT,R,n);
        d       = (a - p)/((q - p)/du);
        u       = u + d;
end

% refined estimate using 1 - exp(-E{m})
%---------------------------------------------------------------------------
d     = 1;
while abs(d) > 1e-6
        p       = spm_P_RF(1,0,u,df,STAT,R,n);
	    q       = spm_P_RF(1,0,u + du,df,STAT,R,n);
        d       = (a - p)/((q - p)/du);
        u       = u + d;
end







% Subfunction for uncorrected threshold for C (approximate)
function ThC = C_u(p,df)
cur   = 0.999999;
step  = 0.025;
nxt   = cur - step;
bLoop = 0;
while ~bLoop
    Pcur = spm_P_RF(1,0,cur,df,'C',1,1);
    Pnxt = spm_P_RF(1,0,nxt,df,'C',1,1);
    prod = (Pcur-p)*(Pnxt-p);
    if (prod<0)
        bLoop = 1;
    else
        cur = cur - step;
        nxt = nxt - step;
    end
end
ThC = nxt;
