function result = evalg(val,coeff,k,scale,sigma,amin,gmin,amax,gmax,anod, gn)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

%result = scale * funcg(log2(k*val)/-scale,amin,gmin,amax,gmax,anod) - (coeff-val).^2 / (2*sigma^2);

pentecoef0 = (1-gmin)/(anod-amin);
pentecoef1 = (gmax-1)/(amax-anod);
coefcorr0 = (8*pentecoef0*sigma*sigma)/log(2);
coefcorr1 = (8*pentecoef1*sigma*sigma)/log(2);
ordor0 = 1 - pentecoef0*anod;
ordor1 = 1 - pentecoef1*anod;

result = coeff;	

if (max(size(val))==1)
	
	if (val==0) 
		return;
	end
	
	if (gn == 0)
		result = (-pentecoef0 .* (log2(k*val))+scale*ordor0-((coeff-val).^2)./(2*sigma^2));
	else
		result = (-pentecoef1 .* (log2(k*val))+scale*ordor1-((coeff-val).^2)./(2*sigma^2));
	end
	
else

	temp_pos = find(val~=0);

	if (gn == 0)
		result(temp_pos) = (-pentecoef0 .* (log2(k.*val(temp_pos)))+scale*ordor0-((coeff(temp_pos)-val(temp_pos)).^2)./(2*sigma^2));
	else
		result(temp_pos) = (-pentecoef1 .* (log2(k.*val(temp_pos)))+scale*ordor1-((coeff(temp_pos)-val(temp_pos)).^2)./(2*sigma^2));
	end
	
end
