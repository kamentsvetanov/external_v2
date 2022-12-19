function erg = fetch_struct_elements(results, data)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

elements = max(size(results));

if (isstruct(data)==0)
	results{elements+1} = cell2mat(data);
else
	
	names = fieldnames(data); 
	
	for i=1:1:max(size(names))
		results = fetch_struct_elements(results, names(i));	
	end
	
end

erg = results;