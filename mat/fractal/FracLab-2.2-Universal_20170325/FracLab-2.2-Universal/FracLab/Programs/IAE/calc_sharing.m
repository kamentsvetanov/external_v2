function [points, curve, polynom] = calc_sharing(Destination_x, Source_x, Source_XLimits, Source_YLimits, window_length, polynom_order, polynom)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

if (isempty(polynom) == 1)
	x = Source_x;

	% window length is procentual
	window_length = window_length*(Source_XLimits(2)-Source_XLimits(1)) /100;

	share = [];
	curve = [];

	for i=1:1:length(x)

		share(i) = length(find(x >= x(i)-window_length/2 & x <= x(i)+window_length/2));
	
	end
	
	share = share./ max(share);
	
	points = Destination_x;
	[x,share] = make_distinct(x,share);

	if (max(points) > max(x))
			x_save = x;
			x = [x,	points(find(points>max(x)))];
			%share = [share, ones(1,length(find(points>max(x_save)))).*floor((Source_YLimits(2)+Source_YLimits(1))/2)];
			share = [share, ones(1,length(find(points>max(x_save)))).*Source_YLimits(1)];
	end
	
	if (min(points) < min(x))
			x_save = x;
			x = [points(find(points<min(x))), x];
			%share = [ones(1,length(find(points<min(x_save)))).*floor((Source_YLimits(2)+Source_YLimits(1))/2), share];
			share = [ones(1,length(find(points<min(x_save)))).*Source_YLimits(1), share];
	end
	
	% check order of polynom
	polynom_order =  max(1,min(polynom_order,floor(length(unique(x))/3)));
	
	% spline fitting
	%curve = spline(x,share,points);

	% Piecewise Cubic Hermite Interpolating Polynomial
	[x,share] = make_distinct(x,share);
	polynom = pchip(x,share);
	curve = ppval(polynom, points);

	% polynomial fitting
	%polynom = polyfit(x,share, polynom_order);
	%curve = polyval(polynom,points);

	curve = min(curve,Source_YLimits(2));
	curve = max(curve,Source_YLimits(1));
	
else
	points = Destination_x;
	curve = ppval(polynom, points);
	curve = min(curve,Source_YLimits(2));
	curve = max(curve,Source_YLimits(1));
end