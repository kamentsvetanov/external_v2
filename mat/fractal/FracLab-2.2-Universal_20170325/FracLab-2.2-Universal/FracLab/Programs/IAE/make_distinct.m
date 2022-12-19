function [x,y] = make_distinct(x,y)
% function to make a data abscissae distinct
% y = f(x)

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

dummy = [1:1:length(x)];

[unique_vals,unique_pos] = unique(x);
dummy(unique_pos) = [];

not_unique = unique(x(dummy));

for i=1:1:length(not_unique)
	y(x == not_unique(i)) = mean(y(x == not_unique(i)));
end

% now reduce the data
[x,pos] = unique(x);
y = y(pos);

