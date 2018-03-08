function [u] = wfu_spm_uc(a,df,STAT,R,n,S)
% corrected critical height threshold at a specified significance level
% FORMAT [u] = wfu_spm_uc(a,df,STAT,R,n,S)
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
% S     - Voxel count
%
% u     - critical height {corrected}
%
%___________________________________________________________________________
%
% spm_uc corrected critical thresholds, using the minimum of different
% valid methods.
%
% See the individual methods for details
%
%     wfu_spm_uc_RF
%     spm_uc_Bonf
%
%___________________________________________________________________________
% @(#)spm_uc.m	2.2 Thomas Nichols 01/07/10

% set global var NOBONF to 1 to turn off Bonferroni.
global NOBONF; if ~isempty(NOBONF) & NOBONF, S = []; end

if (nargin<6), S = []; end

u = wfu_spm_uc_RF(a,df,STAT,R,n);

if ~isempty(S)
  if STAT == 'C'
      bon_u = Inf;  % no Bonferroni for correlation field
  else
      bon_u = spm_uc_Bonf(a,df,STAT,S,n);
  end
  u = min(u,bon_u);
end
