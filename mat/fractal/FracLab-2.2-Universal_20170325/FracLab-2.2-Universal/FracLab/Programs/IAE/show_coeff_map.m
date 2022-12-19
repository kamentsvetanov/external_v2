function show_coeff_map(hObject, eventdata, handles, axes_tag, figure_tag, old_coeff, new_coeff, image_struct, scale, modus)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;

H_axes = bringup_axes(handles, axes_tag);

	set(gca,'XTickLabel',{});
	set(gca,'YTickLabel',{});
[axes_pos] = get(H_axes,'Position');

if (get(H_axes,'UserData')~=1)
	
	set(H_axes,'UserData',1);
	
	b = axes('Parent',findobj('Tag',figure_tag), ...
		'Box','on', ...
		'CameraUpVector',[0 1 0], ...
		'CameraUpVectorMode','manual', ...
		'Color',[1 1 1], ...
		'HandleVisibility','callback', ...
		'Layer','top', ...
		'Units','normalized', ...
		'Position',[axes_pos(1) axes_pos(2) axes_pos(3) axes_pos(4)], ...
		'Tag','spectrum_plot2', ...
		'Visible','off', ...
		'XColor',[0 0 0], ...
		'XTickLabelMode','manual', ...
		'XTickLabel',[], ...
		'XLimMode','manual', ...
		'YColor',[0 0 0], ...
		'YDir','reverse', ...
		'YTickLabelMode','manual', ...
		'YTickLabel',[], ...
		'YLimMode','manual', ...
		'ZColor',[0 0 0]);
	grid off;
	axes(findobj('Tag','spectrum_plot2'));
end

%min(scale,size(old_coeff,2))

%scale


old_coeff = reshape((old_coeff(min(scale,size(old_coeff,2))).vals),1,[]);
new_coeff = reshape((new_coeff(min(scale,size(new_coeff,2))).vals),1,[]);
nz = find(old_coeff>=0);
new_coeff = new_coeff(nz);
old_coeff = old_coeff(nz);
	
k = 1/(max(max(abs(old_coeff))));

sigma = 	image_struct.genotype.sigma;
amin = 		image_struct.genotype.amin;
gmin = 		image_struct.genotype.gmin;
amax = 		image_struct.genotype.amax;
gmax = 		image_struct.genotype.gmax;
anod = 		image_struct.genotype.anod;
filter = 	image_struct.genotype.filter;

echo off;	hold off; echo on;
if (modus == 0)
	
	[x,y]=sort(old_coeff);
	
	plot([0:4/3*max(new_coeff(y))],[0:4/3*max(new_coeff(y))],'y'); echo off;	hold off; echo on;
	echo off;	hold on; echo on;
	plot(x,new_coeff(y),'r.'); 
	
	x1 = amin*100;
	y1 = (gmin+0.000001)*max(new_coeff(y));
	x2 = anod*100;
	y2 = 1*max(new_coeff(y));
	x3 = amax*100;
	y3 = gmax*max(new_coeff(y));

else
		
	y=[];
	x=[];
	for i=0:10:1/k
		y = [y , fminbnd(@argmax, 1/k*2^(-scale*amax), 1/k*2^(-scale*amin), [], i, k, scale, sigma, amin, gmin, amax, gmax, anod) * sign(i) ];
		x = [x , i];	
	end

	plot([0:4/3*max(y)],[0:4/3*max(y)],'y'); 
	echo off;	hold on; echo on;
	plot(x,y,'r'); 
	echo off;	hold off; echo on;
	
	x1 = amin*100;
	y1 = (gmin+0.000001)*max(y);
	x2 = anod*100;
	y2 = 1*max(y);
	x3 = amax*100;
	y3 = gmax*max(y);
	
end


echo off;	hold on; echo on;
	


line([x1,x2,x3],[y1,y2,y3],'Color','k');

plot(x1,y1,'--rs','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','y','MarkerSize',3);
plot(x2,y2,'--rs','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','y','MarkerSize',3);
plot(x3,y3,'--rs','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','y','MarkerSize',3);



refresh;


