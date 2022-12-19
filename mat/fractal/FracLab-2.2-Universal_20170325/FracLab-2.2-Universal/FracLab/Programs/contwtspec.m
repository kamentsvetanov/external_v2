function [alpha,f_alpha,logpart,tau] = contwtspec(wt,scale,Q,FindMax,ChooseReg,varargin)
%   Continuous L2 wavelet based Legendre spectrum
%
%   Estimates the multifractal Legendre spectrum of a 1-D signal from the
%   wavelet coefficients of a L2 continuous decomposition
%
%   1.  Usage
%
%   ______________________________________________________________________
%   [alpha,f_alpha,logpart,tau] = contwtspec(wt,scale,Q[,FindMax,ChooseReg])
%   ______________________________________________________________________
%
%   1.1.  Input parameters
%
%   o  wt : Real or complex matrix [N_scale,N]
%      Wavelet coefficients of a continuous wavelet transform (output of
%      contwt or contwtmir))
%
%   o  scale : real vector  [1,N_scale]
%      Analyzed scale vector
%
%   o  Q :  real vector [1,N_Q]
%      Exponents of the partition function
%
%   o  FindMax : 0/1 flag.
%      FindMax = 0 : estimates the Legendre spectrum from all coefficients
%      FindMax = 1 : estimates the Legendre spectrum from the local Maxima
%      coefficients of the wavelet transform
%      Default value is FindMax = 1
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
%   contwt, cwtspec, cwt1D , dwtspec, FWT
%
%   3.  Examples
%
%   % signal synthesis
%   N = 256 ; H = 0.7 ; Q = linspace(-10,10,41) ;
%   [x] = fbmlevinson(N,H) ;
%   % Continuous Wavelet transform (L2 normalization)
%   wt = contwt(x,[2^(-8),2^(-1)],16,'morletr',8) ;
%   % Legendre Spectrum estimation
%   [alpha,f_alpha,logpart,tau] = contwtspec(wt.coeff,wt.scale,Q,1,1) ;

% Author Paulo Goncalves, June 1997
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

switch nargin
  case 3, FindMax = 1 ; ChooseReg = 0 ; 
  case 4, ChooseReg = 0 ; 
end

nscale = length(scale) ;

if isempty(varargin)
   varargin{1} = 'ls' ;
end


if FindMax == 1 
  maxmap = findWTLM(wt,scale,0.95) ;
elseif FindMax == 0
  maxmap = ones(size(wt)) ;
end

% matrix reshape of the wavelet coefficients

detail = abs(wt.') ; 
maxmap = maxmap.' ;
logscale = log2(scale(:)) ;

% computation of the partition function and the mass function

for nq = 1:length(Q)
  for j=1:nscale
    max_idx = find(maxmap(:,j) == 1) ;
    DetPowQ = detail(max_idx,j).^Q(nq) ;
    logpart(j,nq) = log2(mean(DetPowQ)) ;
  end
end

if ChooseReg == 1
  
  figure('Tag','graph_reg')
  
  reg = 1:nscale ;
  reg_log = reg ;
  
  sth=findobj('Tag','StaticText_error');
  set(sth,'String','Press return to end !');
  %b = uicontrol('Parent',gcf,...
	%'Units','normalized', ...
	%'FontUnits','pixels', ...
	%'FontSize',12, ...
	%'FontWeight','bold', ...
   %'ForegroundColor',[0.9 0 0],...
   %'Position',[0.68 0.02 0.25 0.03], ...
	%'String','Press return to end', ...
	%'Style','text', ...
   %'Tag','info');

  
  while ~isempty(reg_log)   
    
    subplot(121) ;
    plot(logscale,logpart,logscale,logpart,'+'), axis tight
    ylabel('Partition function log_2(S_n(q))'), xlabel('log_{2}(scale)')
    
    reg_log = fracginput(2) ;
    
    if ~isempty(reg_log)
      reg = find(min(reg_log(1,1),reg_log(2,1)) <= logscale & ...
	  logscale <= max(reg_log(1,1),reg_log(2,1))) ;
    end
        
    for nq = 1:length(Q) 
      
      switch varargin{1}
	case 'ls'
	  slope = polyfit(logscale(reg),logpart(reg,nq),1) ;
	case 'wls'  
	  RegWeight = varargin{2}(reg)./sum(varargin{2}(reg)) ;
	  slope = monolr(logscale(reg),logpart(reg,nq),varargin{1},RegWeight) ;
	case {'pls'}
	  slope = monolr(logscale(reg),logpart(reg,nq),varargin{:}) ;
	case {'ml','lapls'}
      slope = monolr(logscale(reg),logpart(reg,nq),varargin{:}) ;
   case {'linf','lsup'}
	slope = regression_elimination(logscale(reg),logpart(reg,nq),varargin{:});   
      end
      
	tau(nq) = slope(1) - 1 - Q(nq)/2 ;
	
    end
    
    % computation of the Legendre spectrum
    
    [f_alpha,alpha] = flt(Q,tau) ;
    subplot(222) 
    plot(alpha,f_alpha) ; title('spectrum') ;
    xlabel('\alpha'),ylabel('f_{\alpha}')
    subplot(224)
    plot(Q,tau) ; title('\tau(q)') ; xlabel('q') ;
    
  end
  
  %%%%%
      FigFRAC= findobj ('Tag','FRACLAB Toolbox');
      sth=findobj(FigFRAC,'Tag','StaticText_error');
      set(sth,'String','');
  %%%%%
  
elseif ChooseReg == 0
  reg = 1:nscale ;
elseif length(ChooseReg) > 1
  reg = ChooseReg ;
end

for nq = 1:length(Q) 
  
  switch varargin{1}
    case 'ls'
      slope = polyfit(logscale(reg),logpart(reg,nq),1) ;
    case 'wls'  
      RegWeight = varargin{2}(reg)./sum(varargin{2}(reg)) ;
      slope = monolr(logscale(reg),logpart(reg,nq),varargin{1},RegWeight) ;
    case {'pls'}
      slope = monolr(logscale(reg),logpart(reg,nq),varargin{:}) ;
    case {'ml','lapls'}
       slope = monolr(logscale(reg),logpart(reg,nq),varargin{:}) ;
    case {'linf','lsup'}
	    slope = regression_elimination(logscale(reg),logpart(reg,nq),varargin{:}) ;   
  end
  
  tau(nq) = slope(1) - 1 - Q(nq)/2 ;
  
end

% computation of the Legendre spectrum

[f_alpha,alpha] = flt(Q,tau) ;



