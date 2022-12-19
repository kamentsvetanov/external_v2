function result = image_spectral_measure2(imgnum)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;




	q=MakeQMF('daubechies',4);
	n=floor(log2(max(size(mydata.images.image(imgnum).CData))));
	
	wt_red		= Wafelet_Transform(mydata.images.image(imgnum).CData(:,:,1), n, q);
	wt_green	= Wafelet_Transform(mydata.images.image(imgnum).CData(:,:,2), n, q);
	wt_blue 	= Wafelet_Transform(mydata.images.image(imgnum).CData(:,:,3), n, q);
	
	mydata.images.image(imgnum).WT = [wt_red wt_green wt_blue];

	wt_red		= Wafelet_Transform(mydata.images.image(1).CData(:,:,1), n, q);
	wt_green	= Wafelet_Transform(mydata.images.image(1).CData(:,:,2), n, q);
	wt_blue 	= Wafelet_Transform(mydata.images.image(1).CData(:,:,3), n, q);
	
	mydata.images.image(1).WT = [wt_red wt_green wt_blue];
	

	spec = calc_frac_spectrum(mydata.images.image(imgnum).WT);
	orig = calc_frac_spectrum(mydata.images.image(1).WT);

	[val,maxpos] = max(spec);
		
	nulls = (find(spec == 0));
	nulls = nulls(find(nulls>maxpos));
	nullpos = nulls(1);

	fit_coeff = polyfit([1:1:maxpos] , spec(1:1:maxpos), 1);
	asc1 = round(fit_coeff(1)*1000)/1000;
	
	fit_coeff = polyfit([maxpos:1:nullpos] , spec(maxpos:1:nullpos), 1);
	desc1 = round(fit_coeff(1)*1000)/1000;
	
	
	[val,maxpos] = max(orig);
		
	nulls = (find(orig == 0));
	nulls = nulls(find(nulls>maxpos));
	nullpos = nulls(1);

	fit_coeff = polyfit([1:1:maxpos] , orig(1:1:maxpos), 1);
	asc2 = round(fit_coeff(1)*1000)/1000;
	
	fit_coeff = polyfit([maxpos:1:nullpos] , orig(maxpos:1:nullpos), 1);
	desc2 = round(fit_coeff(1)*1000)/1000;
	
	
	result = [asc1 , asc2-asc1 , desc1 , desc2-desc1];