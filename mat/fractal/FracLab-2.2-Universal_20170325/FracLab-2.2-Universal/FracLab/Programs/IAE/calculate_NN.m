function results = calculate_NN(filename, minmax, input)
% INPUT:
% filename: path to the file storing the neural network parameters,
% 					alternatively a dupel [layer,Nneuro]=read_NN_from_file(filename);
% minmax: 2xN matrix containing the minmax values of the input values
% input: input matrices grouped in cells
% OUTPUT
% results: output values of the NN grouped in cells

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

results = [];

%--- number of input sets
Nin = size(input,1);

if (ischar(filename) == 1)
	[layer,Nneuro] = read_NN_from_file(filename);
else
	if (size(filename) == [1,2])
		layer = filename{1};
		Nneuro = filename{2};
	else
		error('Wrong input for ''filename''.');
		results = [];
		return;
	end
end
  

if (size(input,2)~=Nneuro)
		error(['Expected and actual count of input variables differ at input #' num2str(i) '.']);
		results = [];
		return;
end


Nmax = minmax(1,:);
Nmin = minmax(2,:);


%--- do calculation of NN output
i = 0;
for i=1:1:Nin
	
	
	
	%--- norming the input values
	input(i,:) = (input(i,:) - Nmin)./(Nmax - Nmin);

	
	output = input(i,:);
	
	for n=1:1:size(layer,2)
		output =  fermi(output * layer{n}');
	end
	
	results = [results; output];
	
end


% --------------------------------------------------------------------
function result = fermi(n)
result = 1./(1+exp(-4*(n-0.5)));