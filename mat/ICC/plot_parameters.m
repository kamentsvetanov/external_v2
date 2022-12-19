function plot_parameters()

spm_figure('GetWin','Graphics');
fg=spm_figure('FindWin','Graphics');
if ~isempty(fg),

    
    Params=load('rp_CNSCNSB.001303.0004.t00000.txt');
	% display results
	% translation and rotation over time series
	%-------------------------------------------------------------------
%	spm_figure('Clear','Graphics');
	ax=axes('Position',[0.1 0.65 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
    plot(Params(:,1:3),'Parent',ax)
	s = ['x translation';'y translation';'z translation'];
	legend(ax, s, 0)
	set(get(ax,'Title'),'String','translation','FontSize',16,'FontWeight','Bold');
	set(get(ax,'Xlabel'),'String','image');
	set(get(ax,'Ylabel'),'String','mm');


	ax=axes('Position',[0.1 0.35 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
	plot(Params(:,1:3),'Parent',ax)
	s = ['x translation';'y translation';'z translation'];
	legend(ax, s, 0)
	set(get(ax,'Title'),'String','translation','FontSize',16,'FontWeight','Bold');
	set(get(ax,'Xlabel'),'String','image');
	set(get(ax,'Ylabel'),'String','mm');


	ax=axes('Position',[0.1 0.05 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
	plot(Params(:,4:6)*180/pi,'Parent',ax)
	s = ['pitch';'roll ';'yaw  '];
	legend(ax, s, 0)
	set(get(ax,'Title'),'String','rotation','FontSize',16,'FontWeight','Bold');
	set(get(ax,'Xlabel'),'String','image');
	set(get(ax,'Ylabel'),'String','degrees');

  
    
	% print realigment parameters
	spm_print
end
return;
%_____________________________________