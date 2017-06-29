function u = wfu_spm_invCcdf(a, df)
% Inverse Cumulative Distribution Function (CDF) for homologous correlation
% FORMAT u = spm_invNcdf(a, df)
%
% a - Uncorrected upper tail probability
% df- Degrees of freedom
% u - Corrlation coefficient which produces F(u) = a
%-----------------------------------------------------------------------------
% 
% wfu_spm_invCcdf calculates the correlation coefficient value corresponding
% to the upper tail probability (or uncorrected p-value) of 1-a, where
% 0<a<1. 
%
% This is derived from the uncorrected p-value from the wfu_spm_P_RF function,
% with the 'C' option for the statistic field.
%
% The formula for this probability can be found in
%
% Cao & Worsley
% The Geometry of Correlation Fields with an Application to Functional
% Connectivity of the Brain.
% Annals of Applied Probability, 4:1021-1057. (1999)
%
%-----------------------------------------------------------------------------
% Version 0.75,  Satoru Hayasaka,  July 31, 2006
%

%-The starting approximate values
x     = min([a/2,a,1-a]);
dx    = 1e-6;



% approximate estimate using E{m}
%---------------------------------------------------------------------------
d     = 1;
while abs(d) > 1e-6
        [P P p] = spm_P_RF(1,0,x,[1 df],'C',1,1);
        [P P q] = spm_P_RF(1,0,x + dx,[1 df],'C',1,1);
        d       = (a - p)/((q - p)/dx);
        x       = x + d;
end

% refined estimate using 1 - exp(-E{m})
%---------------------------------------------------------------------------
d     = 1;
while abs(d) > 1e-6
        p       = spm_P_RF(1,0,x,[1 df],'C',1,1);
        q       = spm_P_RF(1,0,x + dx,[1 df],'C',1,1);
        d       = (a - p)/((q - p)/dx);
        x       = x + d;
end

%-Returning the result
%---------------------------------------------------------------------------
u = x;
