function [erg,coeffs_old,coeffs_new] = Denoise(image_struct, scales)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

global mydata;

if (exist('scales'))
  n = scales;
else
  n = floor(log2(max(size(mydata.images.image(1).CData))));  
end

erg = image_struct;

sigma = 	image_struct.genotype.sigma;
amin = 		image_struct.genotype.amin;
gmin = 		image_struct.genotype.gmin;
amax = 		image_struct.genotype.amax;
gmax = 		image_struct.genotype.gmax;
anod = 		image_struct.genotype.anod;
filter = 	image_struct.genotype.filter;


[q,NAME]=MakeFilter(filter);



	wt_red		= Wafelet_Transform(mydata.images.image(1).CData(:,:,1), n, q);
	wt_green	= Wafelet_Transform(mydata.images.image(1).CData(:,:,2), n, q);
	wt_blue 	= Wafelet_Transform(mydata.images.image(1).CData(:,:,3), n, q);

	erg.WT = [wt_red wt_green wt_blue];
	
	assignin('base' ,'raw_red_wt', wt_red.wt);
	assignin('base' ,'raw_green_wt', wt_green.wt);
	assignin('base' ,'raw_blue_wt', wt_blue.wt);
	
	assignin('base' ,'image_red', double(mydata.images.image(1).CData(:,:,1)));
	assignin('base' ,'image_green', double(mydata.images.image(1).CData(:,:,2)));
	assignin('base' ,'image_blue', double(mydata.images.image(1).CData(:,:,3)));

	
pentecoef0 = (1-gmin)/(anod-amin);
pentecoef1 = (gmax-1)/(amax-anod);
coefcorr0 = (4*pentecoef0*sigma*sigma)/log(2);
coefcorr1 = (4*pentecoef1*sigma*sigma)/log(2);

coeffs_old = struct('vals',{}); %%
coeffs_new = struct('vals',{}); %%


for col=1:1:3
processed_scales = 0; %%

	for scale=1:1:erg.WT(1).scales
	%for scale=5:5
	
		processed_scales = processed_scales +1; %%
		
		%%%Fetch the Coefficients for speciefied Color and Scale
		coeff = WT_Get_Coeff(erg.WT(col),scale);
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		%%%Output old coefficients
		if (col==1)
			if (size(coeffs_old,2) < processed_scales)
 				coeffs_old(processed_scales).vals = coeff; %%
			else
				coeffs_old(processed_scales).vals = [coeffs_old(processed_scales).vals, coeff]; %%
			end
		end
		%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		%%%Calcualation of K
		if (max(max(abs(coeff))) == 0)
			k=0.1;
		else
			k = 1/max(max(abs(coeff)));
		end
		%%%%%%%%%%%%%%%%%%%%


	%Denoise START
	
		%to replace:
		%coeff(elem) = fminbnd(@argmax, 1/k*2^(-scale*amax), 1/k*2^(-scale*amin), [], coeff(elem), k, scale, sigma, amin, gmin, amax, gmax, anod) * sign(coeff(elem));
		%%%%%%%%%%%%

		
		%%%List of all Indexes of coeff, used for Intersections
		p_full_dummy = [1:1:size(coeff,1)*size(coeff,2)]';
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		p_coeff_neg = find(coeff<0);
		p_coeff_pos = p_full_dummy; p_coeff_pos(p_coeff_neg) = [];
		
		signe = zeros(size(coeff,1),size(coeff,2));	
		signe(p_coeff_pos) = 1;
		signe(p_coeff_neg) = -1;
		coeff(p_coeff_neg) = -coeff(p_coeff_neg);
		
		xmin = exp(-amax*scale*log(2))/k;
		xnod = exp(-anod*scale*log(2))/k;
		xmax = exp(-amin*scale*log(2))/k;
	
		delta = coeff.^2-coefcorr0;

		coeff_xg1 = zeros(size(coeff,1),size(coeff,2));
		coeff_xg2 = zeros(size(coeff,1),size(coeff,2));
		coeff_xsol = zeros(size(coeff,1),size(coeff,2));
		
	%
					
		%if (delta<=0) 
				p_delta_neg	= find(delta<=0);
				coeff_xg1(p_delta_neg) = xnod;
		%else
				p_delta_pos = neg(p_delta_neg,p_full_dummy); 
				coeff_xsol(p_delta_pos) = ( coeff(p_delta_pos) + sqrt(delta(p_delta_pos)) )./2;
		
				%if (xsol < xnod)
					p_xsol_less_xnod = find(coeff_xsol < xnod);
										
					coeff_xg1(intersect(p_xsol_less_xnod,p_delta_pos)) = xnod;	
								
				%elseif (xsol <= xmax)
						p_xsol_bigger_or_equal_xnod = neg(p_xsol_less_xnod,p_full_dummy);
						p_xsol_less_or_equal_xmax = find(coeff_xsol<=xmax);	
						p_snapshot = intersect(p_xsol_less_or_equal_xmax,intersect(p_xsol_bigger_or_equal_xnod,p_delta_pos));
						
						v_evalg_xnod_0 = evalg(xnod,coeff,k,scale,sigma,amin,gmin,amax,gmax,anod,0);
						
						%if (evalg(xsol,coeff(elem),k,scale,sigma,amin,gmin,amax,gmax,anod,0) > evalg(xnod,coeff(elem),k,scale,sigma,amin,gmin,amax,gmax,anod,0)) 
								p_evalg_xsol_0_bigger_evalg_xnod_0 = find(evalg(coeff_xsol,coeff,k,scale,sigma,amin,gmin,amax,gmax,anod,0) > v_evalg_xnod_0);
								coeff_xg1(intersect(p_snapshot,p_evalg_xsol_0_bigger_evalg_xnod_0)) = coeff_xsol(intersect(p_snapshot,p_evalg_xsol_0_bigger_evalg_xnod_0));
						%else
								p_evalg_xsol_0_less_or_equal_evalg_xnod_0 = neg(p_evalg_xsol_0_bigger_evalg_xnod_0,p_full_dummy); 
								coeff_xg1(intersect(p_snapshot,p_evalg_xsol_0_less_or_equal_evalg_xnod_0)) = xnod;
						%end
				%else
				
						p_xsol_bigger_or_equal_xnod = neg(p_xsol_less_xnod,p_full_dummy); 
						p_xsol_bigger_xmax = neg(p_xsol_less_or_equal_xmax,p_full_dummy);
						p_snapshot = intersect(p_xsol_bigger_xmax,intersect(p_xsol_bigger_or_equal_xnod,p_delta_pos));
				
						%if (evalg(xmax,coeff(elem),k,scale,sigma,amin,gmin,amax,gmax,anod,0) > evalg(xnod,coeff(elem),k,scale,sigma,amin,gmin,amax,gmax,anod,0)) 
								p_evalg_xmax_0_bigger_evalg_xnod_0 = find(evalg(xmax,coeff,k,scale,sigma,amin,gmin,amax,gmax,anod,0) > v_evalg_xnod_0);
								coeff_xg1(intersect(p_evalg_xmax_0_bigger_evalg_xnod_0,p_snapshot)) = xmax;
						%else
								p_evalg_xmax_0_less_or_equal_evalg_xnod_0 = neg(p_evalg_xmax_0_bigger_evalg_xnod_0,p_full_dummy); 
								coeff_xg1(intersect(p_evalg_xmax_0_less_or_equal_evalg_xnod_0,p_snapshot)) = xnod;
						%end
						
				%end
		%end
		
		delta = coeff.^2 - coefcorr1;
		coeff_xsol = (coeff + sqrt(delta))/2.0;
		
		%if (xsol < xmin) 
			p_xsol_less_xmin = find(coeff_xsol<xmin);
			coeff_xg2(p_xsol_less_xmin) = xmin;
		%elseif (xsol<=xnod)
			p_xsol_bigger_or_equal_xmin = neg(p_xsol_less_xmin,p_full_dummy);
			p_xsol_less_or_equal_xnod = find(coeff_xsol<=xnod);
			
			coeff_xg2(intersect(p_xsol_bigger_or_equal_xmin,p_xsol_less_or_equal_xnod)) = coeff_xsol(intersect(p_xsol_bigger_or_equal_xmin,p_xsol_less_or_equal_xnod));
		%else
			p_snapshot = p_full_dummy; p_snapshot(union(p_xsol_less_or_equal_xnod,p_xsol_less_xmin)) = [];
			coeff_xg2(p_snapshot) = xnod;
		%end
		
		%if (evalg(xg1,coeff(elem),k,scale,sigma,amin,gmin,amax,gmax,anod,0)<evalg(xg2,coeff(elem),k,scale,sigma,amin,gmin,amax,gmax,anod,1)) 
			p_evalg_xg1_0_less_evalg_xg2_1 = find( evalg(coeff_xg1,coeff,k,scale,sigma,amin,gmin,amax,gmax,anod,0) < evalg(coeff_xg2,coeff,k,scale,sigma,amin,gmin,amax,gmax,anod,1) );	
		
			coeff(p_evalg_xg1_0_less_evalg_xg2_1) = coeff_xg2(p_evalg_xg1_0_less_evalg_xg2_1) .* signe(p_evalg_xg1_0_less_evalg_xg2_1);
		%else
			p_evalg_xg1_0_bigger_or_equal_evalg_xg2_1 = neg(p_evalg_xg1_0_less_evalg_xg2_1,p_full_dummy); 
			coeff(p_evalg_xg1_0_bigger_or_equal_evalg_xg2_1) = coeff_xg1(p_evalg_xg1_0_bigger_or_equal_evalg_xg2_1) .* signe(p_evalg_xg1_0_bigger_or_equal_evalg_xg2_1);
		%end
	
	%Denoise END
		
	if (col==1)	
		if (size(coeffs_new,2) < processed_scales)
 			coeffs_new(processed_scales).vals = coeff; %%
		else
			coeffs_new(processed_scales).vals = [coeffs_new(processed_scales).vals, coeff]; %%
		end
	end	
	
		erg.WT(col) = WT_Set_Coeff(erg.WT(col), coeff, scale);
	end %color
end %scale

red 	= Wafelet_Transform_Inverse(erg.WT(1));
green = Wafelet_Transform_Inverse(erg.WT(2));
blue 	= Wafelet_Transform_Inverse(erg.WT(3));

erg.CData = Merge_RGB(red,green,blue);