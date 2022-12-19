function viewmat(Z,X,Y,cmd)
%   Vizualisation of a matrix
%
%   Two dimensional display of a matrix
%
%   1.  Usage
%
%   viewmat(Z,[X,Y,cmd])
%
%   1.1.  Input parameters
%
%   o  Z : Real valued matrix [ny,nx]
%      2-D matrix to be displayed
%
%   o  X : Real  vector [1,nx] or [nx,1]
%      x-axis
%
%   o  Y : Real  vector [1,ny] or [ny,1]
%      Controls the vertical axis.  y forces the vertical axis to be
%      numbered from bottom to top in the increasing order.
%      When not specified, the coordinate system is set to its "Cartesian"
%      axes mode.  The coordinate system origin is at the lower left
%      corner.  The x axis is horizontal and is numbered from left to
%      right.  The y axis is vertical and is numbered from bottom to top.
%
%   o  cmd :  size (1,3) command vector of the form [type scale low
%      threshold high threshold]
%       (Ineffective with Scilab)
%
%   o  type = 0       : image
%
%   o  type = 1    : pseudo color
%
%   o  type = 2    : contour plot
%
%   o  type = 3    : mesh plot
%
%   o  type = 4    : shaded surface with lighting
%
%   o  scale = 0   : linear dynamic
%
%   o  scale = 1   : logarithmic dynamic
%
%   o  low threshold  : scalar setting the minimum level of the display
%      0 < level < +1 for linear scale
%      0 dB < level < Infty dB for logarithmic scale
%
%   o  high threshold : scalar setting the maximum level of the display
%      0 < level < +1 for linear scale
%      0 dB < level < Infty dB for logarithmic scale
%
%       Scilab version:  cmd  is ineffective and frozen to [1 0 0 1] .
%
%   2.  See also:
%
%    Matlab only  : pcolor, image, imagesc, mesh, surfl and plot3
%
%   3.  Examples
%
%   % Matrix synthesis:
%   [x] = oscillsing(1,1,0,128) ;
%   X = x(:)*x(:)' ;
%   % Matrix vizualisation:
%   clf,
%   % Image display with linear dynamic
%   viewmat(abs(X),[0 0 0 1]) ;
%   title('Image display with linear dynamic') ; pause(5) ;
%   % Image display with logarithmic dynamic
%   viewmat(abs(X),[0 1 12 0]) ;
%   title('Image display with logarithmic dynamic') ;  pause(5) ;
%   % Contour plot with linear dynamic
%   viewmat(abs(X),[2 0 0 1]) ;
%   title('Contour plot with linear dynamic') ; pause(5) ;
%   % Mesh plot with linear dynamic
%   viewmat(abs(X),[3 0 0 1]) ;
%   title('Mesh plot with linear dynamic') ; pause(5) ;
%   % Shaded surface with logarithmic dynamic
%   viewmat(abs(X),[4 1 12 0]) ; colormap(gray) ;
%   title('Shaded surface with logarithmic dynamic') ;

% Author Paulo Goncalves & Bertrand Guiheneuf, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

switch (nargin)
  case 1  
    % un seul arg => la matrice
    if ~size(Z,1) > 1 | ~size(Z,2) > 1
      error('Z must be a matrix, not a scalar or vector')
    end
    X = 1:size(Z,2) ;
    Y = 1:size(Z,1) ;
    cmd = [0 0 0 1 1];
    
  case 2
    % deux arg => matrice + cmd
    if ~size(Z,1) > 1 | ~size(Z,2) > 1
      error('Z must be a matrix, not a scalar or vector')
    end
    cmd = X ;
    X = 1:size(Z,2) ;
    Y = 1:size(Z,1) ;
    
  case 3
    % trois arg => matrice + X et Y : la valeur par defaut de cmd est ici differente:
    % le type d'affichage ne peut pas etre 'image', mais 'pcolor'
    if size(X) ~= size(Z) & length(X) ~= size(Z,2)
      error('Matrix dimensions must agree')
    end
    if size(Y) ~= size(Z) & length(Y) ~= size(Z,1)
      error('Matrix dimensions must agree')
    end
    cmd = [1 0 0 1 1];
    
  case 4 
    % quatre arg => matrice + X + Y et cmd
    if size(X) ~= size(Z) & length(X) ~= size(Z,2)
      error('Matrix dimensions must agree')
    end
    if size(Y) ~= size(Z) & length(Y) ~= size(Z,1)
      error('Matrix dimensions must agree')
    end
    
	
end % switch

switch length(cmd)
  case 1 % display mode
    cmd = [cmd 0 0 1 1] ;
  case 2 % display mode + dynamic
    switch cmd(2)
      case 0
	cmd = [cmd 0 1 1];
      case 1
	cmd = [cmd 24 0 1];
      case 2 
	error('Error using viewmat dynamic 2 (linear reverse) : no interval given');
      case 3
	error('Error using viewmat dynamic 3 (log reverse) : no interval given');
      case 4
	cmd = [cmd 0 1 1];
      case 5
	cmd = [cmd 24 0 1];
      case 6
	cmd = [cmd 0 1 1];
      case 7
	cmd = [cmd 24 0 1];
	
    end
  case 3 % Kesako ???
    cmd = [cmd ~cmd(2) 1] ;
    
  case 4 % display mode + dynamic + min + max  
    cmd = [cmd 1];
end

Zmin = min(min(Z)) ;
Zmax = max(max(Z)) ;
a = 1/(Zmax-Zmin) ;
b = -a*Zmin ;
Znorm = a.*Z + b ;

Zinf = cmd(3);
Zsup = cmd(4);

switch cmd(2)
  
  case 0 % linear
    if ( (cmd(3) > 1) | (cmd(3) < 0) | (cmd(4) > 1) | (cmd(4) < 0))
      error('Level out of range (0 <= level <= 1) with minLevel < maxLevel') ;
    else
      sth=findobj('Tag','StaticText_error');
      if isempty(sth)
	disp(['For positive values of Z only, level = ',num2str(max(0,b))]) ;
      end
      if Zsup <= Zinf
	disp('Warning : viewmat : max < min => changing');
	beep;
	tmp = Zinf;
	Zinf = Zsup;
	Zsup = tmp;
      end
      Ztrunc = Znorm;
      pos = find(Ztrunc<Zinf | Ztrunc>Zsup);
      Ztrunc(pos) = 0;
      if (pos & cmd(5) == 0)
	Ztrunc(1,1) = 1;
      end
    end
    
  case 1 % log
    if ((cmd(3) < 0) | (cmd(4) < 0))
      error('Level out of range (level > 0 dB) with minLevel < maxLevel') ;
    else
      Zinf = 10^(-Zinf/10);
      Zsup = 10^(-Zsup/10);
      if Zsup <= Zinf
	disp('Warning : viewmat : max < min => changing');
	beep;
	tmp = Zinf;
	Zinf = Zsup;
	Zsup = tmp;
      end
      Ztrunc = Znorm;
      pos = find(Ztrunc<Zinf | Ztrunc>Zsup);
      Ztrunc(pos) = 0;
      Ztrunc = 10*log10(Ztrunc);
      if (pos & cmd(5) == 0)
	Ztrunc(1,1) = 1;
      end
    end

  case 2 % linear reverse 
    sth=findobj('Tag','StaticText_error');
    if isempty(sth)
      disp(['For positive values of Z only, level = ',num2str(max(0,b))]) ;
    end
    if Zsup <= Zinf
      disp('Warning : viewmat linear reverse : max < min => changing');
      beep;
      tmp = Zinf;
      Zinf = Zsup;
      Zsup = tmp;
    end
    Ztrunc = Znorm;
    pos = find(Ztrunc>Zinf & Ztrunc<Zsup);
    Ztrunc(pos) = 0;
    if (pos & cmd(5) == 0)
      Ztrunc(1,1) = 1;
    end

  case 3 % log reverse
    if ((cmd(3) < 0) | (cmd(4) < 0))
      error('Level out of range (level > 0 dB) with minLevel < maxLevel') ;
    else
      Zinf = 10^(-Zinf/10);
      Zsup = 10^(-Zsup/10);
      if Zsup <= Zinf
	disp('Warning : viewmat log reverse : max < min => changing');
	beep;
	tmp = Zinf;
	Zinf = Zsup;
	Zsup = tmp;
      end
      Ztrunc = Znorm;
      pos = find(Znorm>Zinf & Znorm<Zsup);
      Ztrunc(pos) = 0;
      Ztrunc = 10*log10(Ztrunc);
      if (pos & cmd(5) == 0)
	Ztrunc(1,1) = 1;
      end
    end
    
  case 4 % linear binary 
    Zinf = cmd(3) ;
    Zsup = cmd(4) ;
    if Zsup <= Zinf
      disp('Warning : viewmat linear binary : max < min => changing');
      beep;
      tmp = Zinf;
      Zinf = Zsup;
      Zsup = tmp;
    end
    Ztrunc = Znorm;
    Ztrunc(find(Znorm>=Zinf & Znorm<=Zsup)) = 1;
    Ztrunc(find(Znorm<Zinf | Znorm>Zsup)) = 0;
  
  case 5 % log binary
      Zinf = 10^(-Zinf/10);
      Zsup = 10^(-Zsup/10);
    Zinf = 10^(-cmd(3)/10) ;
    Zsup = 10^(-cmd(4)/10) ;
    if Zsup <= Zinf
      disp('Warning : viewmat log binary : max < min => changing');
      beep;
      tmp = Zinf;
      Zinf = Zsup;
      Zsup = tmp;
    end
    Ztrunc = Znorm;
    Ztrunc(find(Znorm>=Zinf & Znorm<=Zsup)) = 1;
    Ztrunc(find(Znorm<Zinf | Znorm>Zsup)) = 0;
    % Ztrunc = 10*log10(Ztrunc);
    
  case 6 % linear reverse binary 
    sth=findobj('Tag','StaticText_error');
    if isempty(sth)
      disp(['For positive values of Z only, level = ',num2str(max(0,b))]) ;
    end
    Zinf = cmd(3) ;
    Zsup = cmd(4) ;
    if Zsup <= Zinf
      disp('Warning : viewmat : max < min => changing');
      beep;
      tmp = Zinf;
      Zinf = Zsup;
      Zsup = tmp;
    end
    Ztrunc = Znorm;
    Ztrunc(find(Znorm>Zinf & Znorm<Zsup)) = 0;
    Ztrunc(find(Znorm<=Zinf | Znorm>=Zsup)) = 1;

  case 7 % log reverse binary 
    sth=findobj('Tag','StaticText_error');
    if isempty(sth)
      disp(['For positive values of Z only, level = ',num2str(max(0,b))]) ;
    end
    Zinf = 10^(-Zinf/10);
    Zsup = 10^(-Zsup/10);
    if Zsup <= Zinf
      disp('Warning : viewmat : max < min => changing');
      beep;
      tmp = Zinf;
      Zinf = Zsup;
      Zsup = tmp;
    end
    Ztrunc = Znorm;
    Ztrunc(find(Znorm<=Zinf | Znorm>=Zsup)) = 1;
    Ztrunc(find(Znorm>Zinf & Znorm<Zsup)) = 0;
    
    
  otherwise
    error('viewmat : Unknown dynamic option :(');
  
end % switch
    

switch cmd(1)
  case 0
    imagesc(Ztrunc) ; colormap(jet) ; % axis xy ;
  case 1
    pcolor(X,Y,Ztrunc) ; shading flat ; colormap(jet) ;
  case 2
    contour(X,Y,Ztrunc) ; 
  case 3
    mesh(X,Y,Ztrunc) ;
    axis([min(min(X)) max(max(X)) min(min(Y)) max(max(Y)) min(min(Ztrunc)) max(max(Ztrunc))]) ;
  case 4
   surfl(X,Y,Ztrunc) ; shading flat ; colormap(gray) ;
   axis([min(min(X)) max(max(X)) min(min(Y)) max(max(Y)) min(min(Ztrunc)) max(max(Ztrunc))]) ;
 otherwise
   error('viewmat : Unknown type to draw :(');
end 


