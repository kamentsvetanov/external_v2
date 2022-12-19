function results = evaluate_formula(fm, vars, vals)
% No help found

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

results = [];


vars = eval(vars)
for i=1:1:size(vals,1)
	data = mat2cell(vals(i,:))
	results(i) = subs(fm,vars,data)
	
end