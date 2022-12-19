function [HofT,handlefig] = cwttrack(wt,scale,whichT,FindMax,ChooseReg,radius,DeepScale,Show,varargin)
%   Continuous L2 wavelet based Holder exponent estimation
%
%   Estimates the local or global Holder exponent of a 1-D signal from its
%   L2 continuous wavelet transform ( output of contwt(mir) ). In some
%   cases, the global Holder exponent can also be refered to as the long
%   range dependance parameter
%
%   1.  Usage
%
%   ______________________________________________________________________
%   [HofT] = cwttrack(wt,scale,whichT,FindMax,ChooseReg,radius,DeepScale,Show)
%   ______________________________________________________________________
%
%   1.1.  Input parameters
%
%   o  wt : Real or complex matrix [N_scale,N]
%      Wavelet coefficients of a continuous wavelet transform (output of
%      contwt)
%
%   o  scale : real vector  [1,N_scale]
%      Analyzed scale vector
%
%   o  whichT :  Integer
%      whichT, when non zero specifies the time position on the signal
%      where to estimate the local Holder exponent.
%      When whichT is zero, the global scaling exponent (or LRD exponent)
%      is estimated.
%
%   o  FindMax : 0/1 flag.
%      FindMax = 0 : estimates the Holder exponents (local or global) from
%      all coefficients of the wavelet transform
%      FindMax = 1 : estimates the Holder exponents (local or global) from
%      the local Maxima coefficients of the wavelet transform
%      Default value is FindMax = 1
%
%   o  ChooseReg : 0/1 flag or integer vector [1,N_reg], (N_reg <=
%      N_scale) ChooseReg = 0 : full scale range regression
%      ChooseReg = 1 : scale range is choosed by the user, clicking with
%      the mouse on a regression graph.
%      ChooseReg = [n1 ... nN_reg] : imposes the scale indices for the
%      linear regression of the wavelet coefficients versus scale in a
%      log-log plot
%      Default value is  ChooseReg  = 0
%
%   o  radius : Positive integer.
%      The local maxima line search is restricted to some neighbourhood of
%      the analyzed point. Basically, this region is defined by the cone
%      of influence of the wavelet.  radius  allows to modulate the width
%      of the cone.
%      Default value is  cone  = 8 .
%
%   o  DeepScale : strictly positive integer.
%      DeepScale tells the maxima line procedure how depth in scale to
%      scan from step to step.
%      Default value is  DeepScale  = 1
%   o  Show 0/1 flag.
%       Show  = 1 : display the maxima line trajectory and the  log-log
%      regression graph
%       Show  = 0 : no display
%
%   1.2.  Output parameters
%
%   o  HofT : Real scalar.
%      Local or global Holder exponent estimated
%
%   2.  See also:
%
%   cwttrack_all, contwtspec, contwt, dwtspec
%
%   3.  Examples
%
%   % Generalized Weierstrass function synthesis
%     N = 512 ;               % number of points
%     H = 'abs(sin(8*t))' ;   % Holder trajectory
%     l = 2 ;                 % Lambda (geometric progression)
%     tmax = 1 ;              % time extent (0 < t < tmax)
%     RandFlag = 0 ;          % deterministic version
%     t = linspace(0,1,N) ;
%     [x,Ht] = GeneWei(N,H,l,tmax,RandFlag) ;
%     clf ; subplot(211)
%     plot(t,Ht) ;
%     title ('Select with the mouse a time location for estimation (return to quit)') ;
%     hold on
%     subplot(212)
%     plot(t,x) ;
%     title ('Generalized Weierstrass Function') ; xlabel ('time')
%   % Wavelet transform (L2 normalization)
%     wt = contwt(x,[2^(-6),2^(-2)],64,'morleta',12) ;
%   % Local Holder estimation
%     disp('Select with the mouse a time location for estimation (return to quit)...')
%     t  = fracginput(1) ;
%     while ~isempty(t)
%       t = t(1) ;
%       Ht = cwttrack(wt.coeff,wt.scale,round(t*N),0,1,8,1,1) ;
%       subplot(211) ;
%       stem(t,Ht) ;
%       t = fracginput(1) ;
%     end
%     hold off ;

% Author Paulo Goncalves, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

switch nargin
  
  case 1,  error('cwttrack requires at least 2 input arguments') ;
  case 2, whichT = 0 ; FindMax = 1 ; 
    ChooseReg = 0 ; radius = 8 ; DeepScale = 1 ; Show = 0 ;
  case 3, FindMax = 1 ; ChooseReg = 0 ; 
    radius = 8 ; DeepScale = 1 ; Show = 0 ;
  case 4, ChooseReg = 0 ; radius = 8 ; DeepScale = 1 ; Show = 0 ;
  case 5, radius = 8 ; DeepScale = 1 ; Show = 0 ;
  case 6, DeepScale = 1 ; Show = 0 ;
  case 7,  Show = 0 ;
    
end

if  radius < 0, 
  error('radius out of range') , 
end

if DeepScale < 1 | DeepScale > length(scale)
  error('DeepScale out of range') ,
end


nscale = length(scale) ;

if isempty(varargin)
   varargin{1} = 'ls' ;
end

nt = size(wt,2) ;
LogScale = log2(scale) ;

handlefig = [];

if FindMax == 1 
  maxmap = findWTLM(wt,scale) ;
elseif FindMax == 0
  maxmap = ones(size(wt)) ;
end

if whichT == 0
  
  wtsquare = abs(wt.').^2 ;
  maxmap = maxmap' ;
  for j = 1:nscale
    
    nozero = find(maxmap(:,j) == 1) ;
    spec(j) = mean(wtsquare(nozero(:) , j)) ;
    
  end
  
  reg = 1:nscale;
  
  if ChooseReg % Single Time Exponent & Specify Regression Range
  	reg_param = 1;    
  else
  	if Show % Single Time Exponent & Don't Specify Regression Range
  		reg_param = 2;
  	else % Holder function
  		reg_param = 0;
  	end
  end
  
  [HofT,handlefig]=fl_regression(LogScale(reg),log2(spec(reg)),'(a_hat-1)/2','GlobalScalingExponent',reg_param,varargin{:});
  
  
else %whichT ~= 0
  
  if Show & ChooseReg
    figure('Tag','graph_reg') , 

    if FindMax == 1 
      warning off;  
      viewWTLM(maxmap,scale,wt) ;
      warning backtrace;
      colormap(gray) ;
    else
      viewmat(abs(wt),1:size(wt,2),log2(scale),[1 1 24 0]) ;
      colormap(gray) ;
    end
    axis([whichT-100  whichT+100 0 log2(max(scale))]) ;
    hold on ;
  end
  
  % seeks for the closest local maximum to whichT. 
  % The left neighboor has priority
  
  IncLag = -1 ;
  Lag = maxmap(1,whichT) ;
  while all(~Lag)
    
    IncLag = IncLag + 1 ;
    Lag = maxmap( 1 , max(1 , whichT-IncLag) : min(whichT + IncLag , nt)  ) ;
    
  end
  
  if Lag(1) == 1 , closeT = min(whichT - IncLag , nt) ;
  else , closeT = max(whichT + IncLag , 1) ; end
  
  
  % INITIALISATION
  
  
  Dmin = 0 ; 
  Dthreshold = TSdist( 1,0,scale(2),radius ) ;
  
  ThisTime = closeT   ; ThisScale = 1 ; 
  NextTime = ThisTime ; NextScale = ThisScale ;
  
  while ~isempty(ThisTime) & ...
	ThisScale <= nscale - DeepScale & ...
	Dmin < Dthreshold
    
    ConeT = zeros(DeepScale,1) ; ConeS = [] ; 
    
    Dthreshold = TSdist( scale(ThisScale),0, ...
	scale(ThisScale+DeepScale), ...
	scale(ThisScale+DeepScale) * radius ) ;
    
    
    for j = 1 : DeepScale
      
      
      ConeInf = max( 1 , closeT - round(radius * scale(ThisScale + j)) ) ;
      ConeSup = min( nt , closeT + round(radius * scale(ThisScale + j)) ) ;
      AllT = find( maxmap( ThisScale + j , ConeInf : ConeSup ) ) + ... 
	  max( 0 , closeT - round(radius * scale(ThisScale + j)) - 1 ) ;
      
      for n = 1 : length(AllT) 
	ConeT(j,n) = AllT(n) ;
      end
      
    end
    
    ConeT(find(~ConeT)) = NaN * ones(size(find(~ConeT))) ;
    ConeS = scale(ones(size(ConeT,2),1),ThisScale+1 : ThisScale+DeepScale)' ;
    
    if all(isnan( ConeT ))
      
      D = [] ; ThisTime = [] ; 
      
    else
      
      D = TSdist(scale(ThisScale),ThisTime,ConeS,ConeT) ;
      Dmin = min(min(D)) ;
      [ Smin , Tmin ] = find( D == Dmin ) ;
      ThisTime = ConeT( Smin(1) , Tmin(1) ) ;
      ThisScale = ThisScale + Smin(1) ;
      if Dmin < Dthreshold 
	
	NextTime  = [ NextTime ThisTime ] ;
	NextScale = [ NextScale ThisScale ] ;
	
      end
      
    end
    
  end
  
  if Show & ChooseReg
    plot(closeT+radius*scale,LogScale,'r',closeT-radius*scale,LogScale,'r') ;
    plot(NextTime,log2(scale(NextScale)),'ow') ; pause(1) ; hold off 
  end
  
  for n = 1 : length(NextScale) 
    LineWT(n)  = abs(wt( NextScale(n) , NextTime(n) ) ) ;
  end
  
  LogScale = log2(scale(NextScale)) ;
  LogLine = log2(abs(LineWT).^2) ;
  
  reg = 1:length(NextScale) ;
  

  if ChooseReg % Single Time Exponent & Specify Regression Range
  	reg_param = 1;    
  else
  	if Show % Single Time Exponent & Don't Specify Regression Range
  		reg_param = 2;
  	else % Holder function
  		reg_param = 0;
  	end
  end

  [HofT,handlefig]=fl_regression(LogScale(reg),LogLine(reg),'(a_hat-1)/2','LocalHolderExponent',reg_param,varargin{:});      
  
end


