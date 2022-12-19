function result = read_configuration_from_file(config, filename)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

result = config;

fid = fopen(filename,'r');


while (feof(fid) == 0)
	data = fgetl(fid);
	pos = strfind(data,'//');
	
	if (isempty(pos) == 0)
		data = data(1:1:pos(1)-1);
	end
	
	if (isempty(data) == 0)
		eval(['result.' data ';']);
	end
end
	

	
	
fclose(fid);