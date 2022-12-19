function    genotype_thumb_ButtonDownFcn(hObject, eventdata, handles, component)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;

axes_position = get(gca,'Position');
axes_start_point = get(gca,'CurrentPoint');
fig_start_point = get(gcf,'CurrentPoint');

rect = [fig_start_point(1,1)-5 fig_start_point(1,2)-5 10 10];
rect_end_position = dragrect(rect);

x_axes_range = get(gca,'XLim');
y_axes_range = get(gca,'YLim');

rect_end_position(1) = min(max(rect_end_position(1)+5,axes_position(1)),axes_position(1)+axes_position(3));
rect_end_position(2) = min(max(rect_end_position(2)+5,axes_position(2)),axes_position(2)+axes_position(4));


xval = scale_value(rect_end_position(1), axes_position(1), axes_position(1)+axes_position(3), x_axes_range(1), x_axes_range(2));
xval = xval/mydata.config.frac_spectrum_values * mydata.config.frac_spectrum_max_coeff;
xval = min(max(xval,0),mydata.config.evol_amax_max);

yval = scale_value(rect_end_position(2), axes_position(2), axes_position(2)+axes_position(4), y_axes_range(1), y_axes_range(2));
yval = max(yval,0);
yval = sqrt(yval);
yval = min(yval,1);

if (component == 1) %[amin,gmin]
    xval = min(xval,mydata.images.image(8).genotype.anod-0.00001);
    yval = min(max(yval,mydata.config.evol_gmin_min),mydata.config.evol_gmin_max);
    
    set(findobj('Tag','edit_amin'),'String',num2str(xval));
    set(findobj('Tag','edit_gamin'),'String',num2str(yval));
    
elseif (component == 2) %[anod]
    xval = max(min(xval,mydata.images.image(8).genotype.amax-0.00002),mydata.images.image(8).genotype.amin+0.00001);
    yval = 1;
    
    set(findobj('Tag','edit_anod'),'String',num2str(xval));
    
elseif (component == 3) %[amax,gmax]
    xval = max(xval,mydata.images.image(8).genotype.anod+0.00001);
    yval = min(max(yval,mydata.config.evol_gmax_min),mydata.config.evol_gmax_max);
        
    set(findobj('Tag','edit_amax'),'String',num2str(xval));
    set(findobj('Tag','edit_gamax'),'String',num2str(yval));
end

mydata.images.image(8).genotype.sigma = 	str2double(get(findobj('Tag','edit_sigma'),'String'));
mydata.images.image(8).genotype.amin = 	str2double(get(findobj('Tag','edit_amin'),'String'));
mydata.images.image(8).genotype.gmin = 	str2double(get(findobj('Tag','edit_gamin'),'String'));
mydata.images.image(8).genotype.amax = 	str2double(get(findobj('Tag','edit_amax'),'String'));
mydata.images.image(8).genotype.gmax = 	str2double(get(findobj('Tag','edit_gamax'),'String'));
mydata.images.image(8).genotype.anod = 	str2double(get(findobj('Tag','edit_anod'),'String'));


[thumb_handles] = show_spectrum(hObject, eventdata, handles, 'spectrum_axes','fig_adjust', 1);
set(thumb_handles(1),'ButtonDownFcn',{@genotype_thumb_press, handles, 1});
set(thumb_handles(2),'ButtonDownFcn',{@genotype_thumb_press, handles, 2});
set(thumb_handles(3),'ButtonDownFcn',{@genotype_thumb_press, handles, 3});
