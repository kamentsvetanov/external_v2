function result = calc_frac_spectrum(wt)
% Calculate Multifractal Spectrum
% wt the results from Wafelet Transformation

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;

wt_red = wt(1);
wt_green = wt(2);
wt_blue = wt(3);

scale = wt_red.scales;
bricks = mydata.config.frac_spectrum_values;
max_coeff = mydata.config.frac_spectrum_max_coeff;
erg = zeros(1,bricks);

%coeffs = [WT_Get_Coeff(wt_red,scale),WT_Get_Coeff(wt_green,scale),WT_Get_Coeff(wt_blue,scale)]; 

	
	%coeffs = coeffs(2:1:2,:);
	%coeffs = reshape(coeffs,1,[]);
	
	coeffs_red = [WT_Get_Coeff(wt_red,scale),WT_Get_Coeff(wt_red,scale-1)];
	coeffs_red = nonzeros(coeffs_red);
	K = 1/max(abs(coeffs_red));
	vals_red = -log2(K * abs(coeffs_red))./scale;

	
	coeffs_green = [WT_Get_Coeff(wt_green,scale),WT_Get_Coeff(wt_green,scale-1)];
	coeffs_green = nonzeros(coeffs_green);
	K = 1/max(abs(coeffs_green));
	vals_green = -log2(K * abs(coeffs_green))./scale;

	
	coeffs_blue = [WT_Get_Coeff(wt_blue,scale),WT_Get_Coeff(wt_blue,scale-1)];
	coeffs_blue = nonzeros(coeffs_blue);
	K = 1/max(abs(coeffs_blue));
	vals_blue = -log2(K * abs(coeffs_blue))./scale;

	
	vals = [vals_red; vals_green; vals_blue];
	
	vals = vals(find(vals>0 & vals<=max_coeff));

	% norming the abszisse
	%max_coeff = ceil(max(vals));
	
	
for i=1:1:size(vals,1)
		erg( ceil(bricks*vals(i)/max_coeff) ) = erg( ceil(bricks*vals(i)/max_coeff) ) + 1;
end

	
%erg = hist(vals,bricks); 
	
% smoothing the plot
%windowSize=ceil(bricks/25);
%windowSize = 4;
%erg = filter(ones(1,windowSize)/windowSize,1,erg);


erg(find(erg~=0)) = log2(erg(find(erg~=0)))/log2(max(abs(erg(find(erg~=0)))));


result = erg;

