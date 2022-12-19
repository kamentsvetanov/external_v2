function [points, curve, polynom] = calc_fitness(Destination_x, Source_x, Source_y, Source_XLimits, Source_YLimits, polynom_order, polynom)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

warning off MATLAB:polyfit:PolyNotUnique;

if (isempty(polynom) == 1)

	[x,y] = make_distinct(Source_x, Source_y);

	points = Destination_x;

	if (max(points) > max(x))
			x_save = x;
			x = [x,	points(find(points>max(x)))];
			%y = [y, ones(1,length(find(points>max(x_save)))).*floor((Source_YLimits(2)+Source_YLimits(1))/2)];
			y = [y, ones(1,length(find(points>max(x_save)))).*Source_YLimits(1)];
	end
	
	if (min(points) < min(x))
			x_save = x;
			x = [points(find(points<min(x))), x];
			%y = [ones(1,length(find(points<min(x_save)))).*floor((Source_YLimits(2)+Source_YLimits(1))/2), y];
			y = [ones(1,length(find(points<min(x_save)))).*Source_YLimits(1), y];
	end
	
	polynom_order =  max(1,min(polynom_order,floor(length(unique(x))/2)));
	%[max(x), max(points), polynom_order]
	
	% spline fitting
	%curve = spline(x,y,points);

	% Piecewise Cubic Hermite Interpolating Polynomial
	%polynom = pchip(x,y);
	%curve = ppval(polynom, points);

	% polynomial fitting
	polynom = polyfit(x,y,polynom_order);
	curve = polyval(polynom,points);


	while ( (length(find(curve>Source_YLimits(2)) > 0) || length(find(curve<Source_YLimits(1)) > 0)) && polynom_order>1)
		polynom_order = polynom_order - 1;

		% polynomial fitting
		polynom = polyfit(x,y,polynom_order);
		curve = polyval(polynom,points);	
	end

	curve = min(curve,Source_YLimits(2));
	curve = max(curve,Source_YLimits(1));
	
else
	
	points = Destination_x;
	curve = polyval(polynom,points);	
	curve = min(curve,Source_YLimits(2));
	curve = max(curve,Source_YLimits(1));
	
end
	