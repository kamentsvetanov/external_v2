function [layer,Nneuro] = read_NN_from_file(filename)
% --- read NN from Pythia file

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

fidn = fopen(filename,'r');

%--- skip general informations
for i=1:1:9
	waste = fgetl(fidn);
end

% --- save current position of file pointer
pos = ftell(fidn);

% --- read first line to measure number of inputs
waste = fgetl(fidn);
Nneuro = size( eval(['[' waste ']']) )-2;

% --- reset file pointer to saved position
fseek(fidn, pos, 'bof');

% -- fetch the weights of the Neural Network
c = 0;
layer = [];

while (feof(fidn)==0)
	data = eval(['[' fgetl(fidn) ']']);
	
	if (data(1)>c)
		c = data(1);
		layer{c} =  data(3:size(data,2));
	else
		c = data(1);
		layer{c} =  [layer{c} ; data(3:size(data,2))];
	end
	
end

fclose(fidn);

