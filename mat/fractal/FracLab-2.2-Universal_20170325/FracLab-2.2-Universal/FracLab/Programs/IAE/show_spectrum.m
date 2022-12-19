function [thumb_handles] = show_spectrum(hObject, eventdata, handles, axes_tag, figure_tag, do_refresh)
% Calculate and display the multifractal spectrum of an image

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;

if (exist('do_refresh') && do_refresh == 0 || length(mydata.images.image(8).WT)<3 || length(mydata.images.image(1).WT)<3)
    %img_num = get(mydata.images.analysedimage,'UserData');

        %debug = 'WT berechnen...'
        q=MakeQMF('daubechies',4);
        n=floor(log2(max(size(mydata.images.image(8).CData))));

        wt_red		= Wafelet_Transform(mydata.images.image(8).CData(:,:,1), n, q);
        wt_green	= Wafelet_Transform(mydata.images.image(8).CData(:,:,2), n, q);
        wt_blue 	= Wafelet_Transform(mydata.images.image(8).CData(:,:,3), n, q);

        mydata.images.image(8).WT = [wt_red wt_green wt_blue];


    %if (isstruct(mydata.images.image(1).WT) == 0)
        %debug = 'WT berechnen...'
        q=MakeQMF('daubechies',4);
        n=floor(log2(max(size(mydata.images.image(1).CData))));

        wt_red		= Wafelet_Transform(mydata.images.image(1).CData(:,:,1), n, q);
        wt_green	= Wafelet_Transform(mydata.images.image(1).CData(:,:,2), n, q);
        wt_blue 	= Wafelet_Transform(mydata.images.image(1).CData(:,:,3), n, q);

        mydata.images.image(1).WT = [wt_red wt_green wt_blue];
    %end
end

%catch axes handle to draw int
    bringup_axes(handles, axes_tag);

	echo off;	hold off; echo on;

	spec_original = calc_frac_spectrum(mydata.images.image(1).WT);
	spec_modified = calc_frac_spectrum(mydata.images.image(8).WT);

	
	plot(1:1:mydata.config.frac_spectrum_values,spec_original,'g.',1:1:mydata.config.frac_spectrum_values,spec_modified,'r.');

	
	echo off;	hold on; echo on;
	
	x1 = mydata.images.image(8).genotype.amin*mydata.config.frac_spectrum_values/mydata.config.frac_spectrum_max_coeff;
	y1 = mydata.images.image(8).genotype.gmin^2;
	x2 = mydata.images.image(8).genotype.anod*mydata.config.frac_spectrum_values/mydata.config.frac_spectrum_max_coeff;
	y2 = 1;
	x3 = mydata.images.image(8).genotype.amax*mydata.config.frac_spectrum_values/mydata.config.frac_spectrum_max_coeff;
	y3 = mydata.images.image(8).genotype.gmax^2;

	
	line([x1,x2,x3],[y1,y2,y3]);
	
	M1 = plot(x1,y1,'--rs','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','y','MarkerSize',5);
	M2 = plot(x2,y2,'--rs','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','y','MarkerSize',5);
	M3 = plot(x3,y3,'--rs','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','y','MarkerSize',5);
	
    thumb_handles = [M1,M2,M3];
    
   
	set(gca,'XTickLabel',{});
	set(gca,'YTickLabel',{});
	%set(gca,'YScale','log');
	set(gca,'YLim',[-0.1 1.1]);
	set(gca,'XLim',[-mydata.config.frac_spectrum_values/40 max(mydata.config.frac_spectrum_values,x3)]);
	set(gca,'Color','none');
	set(gca,'XColor','k');
	set(gca,'YColor','k');

	echo off; hold off; echo on;
    
