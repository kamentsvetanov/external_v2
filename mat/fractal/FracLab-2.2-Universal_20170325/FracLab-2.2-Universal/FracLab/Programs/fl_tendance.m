function f = fl_tendance(x,nb_zones)
%Estimate the trend of a 1D or 2D signal using splines (fast !)
% Modified by Pierrick Legrand, November 2016

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if min(size(x)) == 1
%1D
  N = length(x);
  
  %Splines avec points trouvés par moyennage
  %nb_zones = 20;
  zones = linspace(1,N,nb_zones+1);
  
  for i=1:nb_zones
      splinex(i) = (zones(i)+zones(i+1))/2;
      spliney(i) = nanmean(x(floor(zones(i)):floor(zones(i+1))));
  end
  
  %f = spline(splinex,spliney,1:N);
  f =  interp1(splinex,spliney,1:N,'pchip');
else
%2D
  [n1 n2] = size(x);
  z0 = zeros(nb_zones);
  for i = 1:(n1-1)/nb_zones:n1-1
  	for j = 1:(n2-1)/nb_zones:n2-1
  	 i0 = round(1+nb_zones/(n1-1)*(i-1));
  	 j0 = round(1+nb_zones/(n2-1)*(j-1));
  	 z0(i0,j0) = nanmean(nanmean(x(round(i+n1/nb_zones),round(j+n2/nb_zones))));
  	end
  end
  
  [x0,y0] = meshgrid(0:1/(nb_zones-1):1,0:1/(nb_zones-1):1);
  [xi,yi] = meshgrid(0:1/(n1-1):1,0:1/(n2-1):1); 
  
  f = interp2(x0,y0,z0,xi,yi,'cubic')';
end

%f=reshape(f,size(x));