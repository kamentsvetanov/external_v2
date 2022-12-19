function [H_plots,H_axes,Index] = plot_gene(handles, axes_tag, fitness_checkbox_tag, sharing_checkbox_tag, sharing_fitness_checkbox_tag, refresh_bool, trend_bool, X, Y, XLimits ,Marker, MarkerEdgeColor, MarkerSize, MarkerFaceColor, BackGroundColor, Fitness_TrendMarker, Fitness_TrendMarkerSize, Sharing_TrendMarker, Sharing_TrendMarkerSize, Sharing_Fitness_TrendMarker, Sharing_Fitness_TrendMarkerSize)
% --- function to plot the genes easily
% returns handle to the plots

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

[vals,vals_idx] = sort(X);
Index = vals_idx;
H_axes = bringup_axes(handles, axes_tag);


if (refresh_bool == 0)
	echo off;	hold on; echo on;
else
	echo off;	hold off; echo on;
end

if (trend_bool == 1)
	warning off MATLAB:polyfit:RepeatedPointsOrRescale;
	x = vals;
	y = Y(vals_idx);

	if (get(findobj('Tag',fitness_checkbox_tag),'Value') == 1 || get(findobj('Tag',sharing_fitness_checkbox_tag),'Value') == 1)
		[points_fitness, curve_fitness, polynom_fitness] = calc_fitness([min(x):(max(x)-min(x))/70:max(x)], x, y, XLimits, [-6,6], 100, []);
		%[points_fitness, curve_fitness, polynom_fitness] = calc_fitness([XLimits(1):(XLimits(2)-XLimits(1))/60:XLimits(2)], x, y, XLimits, [-6,6], 200, []);
		%curve_fitness = scale_value(curve_fitness, min(curve_fitness), max(curve_fitness), -6, 6);
	end
	
	if (get(findobj('Tag',sharing_checkbox_tag),'Value') == 1 || get(findobj('Tag',sharing_fitness_checkbox_tag),'Value') == 1)
		[points_sharing, curve_sharing, polynom_sharing] = calc_sharing([min(x):(max(x)-min(x))/70:max(x)], x, XLimits, [0,1], 15, 100, []);
		%[points_sharing, curve_sharing, polynom_sharing] = calc_sharing([XLimits(1):(XLimits(2)-XLimits(1))/60:XLimits(2)], x, XLimits, [0,1], 15, 200, []);
		curve_sharing = scale_value(1-curve_sharing, 0, 1, -6, 6);
	end

	if (get(findobj('Tag',fitness_checkbox_tag),'Value') == 1)
		plot(points_fitness,curve_fitness, Fitness_TrendMarker,'MarkerSize',Fitness_TrendMarkerSize);
		echo off;	hold on; echo on;
	end
	
	if (get(findobj('Tag',sharing_checkbox_tag),'Value') == 1)
		plot(points_sharing, curve_sharing, Sharing_TrendMarker,'MarkerSize',Sharing_TrendMarkerSize);
		echo off;	hold on; echo on;	
	end

	if (get(findobj('Tag',sharing_fitness_checkbox_tag),'Value') == 1)
		points_sharing_fitness = points_fitness;
		
		curve_sharing_fitness = scale_value(curve_fitness,-6,6,0,1) .* (scale_value(curve_sharing, -6, 6, 0, 1));
		
		%[min(curve_fitness),max(curve_fitness), min(curve_sharing),max(curve_sharing), min(curve_sharing_fitness),max(curve_sharing_fitness)]
		% scale the timeseries to do a nice plot
		curve_sharing_fitness = scale_value(curve_sharing_fitness, 0, 1, -6, 6);
		 
		%curve_sharing_fitness = curve_sharing_fitness - min(curve_sharing_fitness);
		
		plot(points_sharing_fitness,curve_sharing_fitness, Sharing_Fitness_TrendMarker,'MarkerSize',Sharing_Fitness_TrendMarkerSize);
		echo off;	hold on; echo on;	
	end
	
	
end

H_plots = [];
for i=1:1:length(vals)
	H_plots = [H_plots, plot(vals(i),Y(vals_idx(i)),Marker,'MarkerEdgeColor',MarkerEdgeColor,'MarkerSize',MarkerSize,'MarkerFaceColor',MarkerFaceColor)];
	echo off;	hold on; echo on;
end


echo off;	hold off; echo on;



set(H_axes,'YTickLabel',[-6,0,6]);
set(H_axes,'YTick',[-6,0,6]);
set(H_axes,'YAxisLocation','right');
set(H_axes,'YLim',[-7,7]);
set(H_axes,'Color',BackGroundColor);

set(H_axes,'XLim',XLimits);	
set(H_axes,'XColor','k');	
set(H_axes,'YColor',[0.7,0.1,0.1]);	
