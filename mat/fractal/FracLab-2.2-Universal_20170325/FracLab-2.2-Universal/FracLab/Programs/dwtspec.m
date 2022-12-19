function [alpha,f_alpha,logpart,tau] = dwtspec(wt,Q,ChooseReg,varargin)
%   Discrete wavelet based Legendre spectrum
%
%   Estimates the multifractal Legendre spectrum of a 1-D signal from the
%   wavelet coefficients of a discrete decomposition
%
%   1.  Usage
%
%   ______________________________________________________________________
%   [alpha,f_alpha,logpart] = dwtspec(wt,Q[,ChooseReg])
%   ______________________________________________________________________
%
%   1.1.  Input parameters
%
%   o  wt : Real vector [1,N]
%      Wavelet coefficients of a discrete wavelet transform (output of
%      FWT)
%
%   o  Q :  real vector [1,N_Q]
%      Exponents of the partition function
%
%   o  ChooseReg : 0/1 flag or integer vector [1,N_reg], (N_reg <=
%      N_scale) ChooseReg = 0 : full scale range regression
%      ChooseReg = 1 : asks online the scale indices setting the range for
%      the linear regression of the partition function.
%      ChooseReg = [n1 ... nN_reg] : scale indices for the linear
%      regression of the partition function.
%
%   1.2.  Output parameters
%
%   o  alpha : Real vector [1,N_alpha], N_alpha <= N_Q
%      Singularity support of the multifractal Legendre spectrum
%
%   o  f_alpha : real vector [1,N_alpha]
%      Multifractal Legendre spectrum
%
%   o  logpart : real matrix [N_scale,N_Q]
%      Log-partition function
%
%   o  tau : real vector [1,N_Q]
%      Regression function
%
%   2.  See also:
%
%   cwtspec, FWT, WTStruct, MakeQMF, flt, iflt
%
%   3.  Examples
%
%   % signal synthesis
%   N = 256 ; H = 0.7 ; Q = linspace(-10,10,41) ;
%   [x] = fbmlevinson(N,H) ;
%   % Discrete Wavelet transform
%   qmf = MakeQMF('daubechies',2) ;
%   [wt] = FWT(x,log2(N),qmf) ;
%   % Legendre Spectrum estimation
%   [alpha,f_alpha,logpart,tau] = dwtspec(wt,Q,1) ;

% Author Paulo Goncalves, June 1997
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

switch nargin
  case 2, ChooseReg = 0 ;
end

if isempty(varargin)
   varargin{1} = 'ls' ;
end


[sc_idx,sc_lg] = WTStruct(wt) ;

nscale = length(sc_idx)-1 ;
logscale = 1:nscale ;
wt = abs(wt) ;

% matrix reshape of the wavelet coefficients

detail = cell(1,nscale) ;
for j=1:nscale
  detail{j} = wt(sc_idx(j):sc_idx(j)+sc_lg(j)-1).' ; 
end

% computation of the partition function and the mass function

for nq = 1:length(Q)
  for j=1:nscale
     logpart(j,nq) = log2(sum((detail{j}).^Q(nq))) ;
  end
end
if ChooseReg == 1
  
  if isempty(findobj('Tag','graph_reg'))
    figure('Tag','graph_reg')
  else
    figh = findobj('Tag','graph_reg') ; 
    figure(figh) ; %clf
  end
 
  sth=findobj('Tag','StaticText_error');
  set(sth,'String','Press return to end !');
 %b = uicontrol('Parent',gcf,...
%	'FontUnits','pixels', ...
%	'FontSize',12, ...
%	'Units','normalized', ...
%	'FontWeight','bold', ...
%   'ForegroundColor',[0.9 0 0],...
%   'Position',[0.68 0.02 0.25 0.03], ...
%	'String','Press return to end', ...
%	'Style','text', ...
%   'Tag','info');
 
  reg = 1:nscale ;
  reg_log = reg ;
  
  while ~isempty(reg_log)     
    
    figh = findobj('Tag','graph_reg') ;
    figure(figh) ;
    subplot(121) ;
    plot(logscale,logpart,logscale,logpart,'+') , axis tight
    ylabel('Partition function log_2(S_n(q))'), xlabel('log_{2}(scale)')
    
    reg_log = fracginput(2) ; 
    if ~isempty(reg_log)
      reg = find(min(reg_log(1,1),reg_log(2,1)) <= logscale & ...
	  logscale <= max(reg_log(1,1),reg_log(2,1))) ;
    end
    
    for nq = 1:length(Q) 
%      slope = polyfit(reg(:),logpart(reg,nq),1) ;
      
    switch varargin{1}
      case 'ls'
	slope = polyfit(reg(:),logpart(reg,nq),1) ;
      case 'wls'  
	RegWeight = varargin{2}(reg)./sum(varargin{2}(reg)) ;
	slope = monolr(reg(:),logpart(reg,nq),varargin{1},RegWeight) ;

      case {'pls'}
	slope = monolr(reg(:),logpart(reg,nq),varargin{:}) ;

      case {'ml','lapls'}
	slope = monolr(reg(:),logpart(reg,nq),varargin{:}) ;
   
      case {'linf','lsup'}
	slope = regression_elimination(reg(:),logpart(reg,nq),varargin{:}) ;  
    end
      
      
      tau(nq) = slope(1)-Q(nq)/2 ;
    end
    
    % computation of the Legendre spectrum
    
    [f_alpha,alpha] = flt(Q,tau) ;
    subplot(222) 
    plot(alpha,f_alpha) ; title('spectrum') ;
    subplot(224)
    plot(Q,tau) ; title('\tau(q)') ; xlabel('q') ;
    
  end

elseif ChooseReg == 0
  reg = 1:nscale ;
elseif length(ChooseReg) > 1
  reg = ChooseReg ;
end

%%%%%
  FigFRAC= findobj ('Tag','FRACLAB Toolbox');
  sth=findobj(FigFRAC,'Tag','StaticText_error');
  set(sth,'String','');
%%%%%
for nq = 1:length(Q) 
  %  slope = polyfit(reg(:),logpart(reg,nq),1) ;
  
  switch varargin{1}
    case 'ls'
      slope = polyfit(reg(:),logpart(reg,nq),1) ;
    case 'wls'  
      RegWeight = varargin{2}(reg)./sum(varargin{2}(reg)) ;
      slope = monolr(reg(:),logpart(reg,nq),varargin{1},RegWeight) ;
      
    case {'pls'}
      slope = monolr(reg(:),logpart(reg,nq),varargin{:}) ;
      
    case {'ml','lapls'}
      slope = monolr(reg(:),logpart(reg,nq),varargin{:}) ;
      
    case {'linf','lsup'}
	slope = regression_elimination(reg(:),logpart(reg,nq),varargin{:}) ;  
  end
  
  tau(nq) = slope(1)-Q(nq)/2 ;
end

% computation of the Legendre spectrum

[f_alpha,alpha] = flt(Q,tau) ;





