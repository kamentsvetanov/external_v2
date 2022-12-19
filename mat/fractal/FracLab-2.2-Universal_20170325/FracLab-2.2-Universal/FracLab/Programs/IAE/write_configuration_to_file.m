function write_configuration_to_file(config,filename)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

fid = fopen(filename,'w');

data = fetch_struct_elements({}, config);


for i=1:1:max(size(data))
	
	value = eval(['config.' data{i}]);

	
	if (ischar(value) == 1)
		output = [data{i} '=' value];
	else
		output = [data{i} '=' mat2str(value)];	
	end
	
	
	fprintf(fid,'%s\n',output);
	
end

fclose(fid);