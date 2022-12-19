function result = image_spectral_measure(imgnum)
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



	spec_original = calc_frac_spectrum(mydata.images.image(1).WT);
	spec_modified = calc_frac_spectrum(mydata.images.image(imgnum).WT);

	[val1,pos1] = max(spec_original);
	[val2,pos2] = max(spec_modified);
		
	mass1 = size(find(spec_original > min(spec_original)),2);
	mass2 = size(find(spec_modified > min(spec_modified)),2);
	
	
	result = [pos2, pos2-pos1, mass2, mass2-mass1];