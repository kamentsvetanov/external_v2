function L = lambda(lambdais)
%   Extracts of the lambda_i's from the structure that contains them.
%
%   1.  Usage
%
%   [L] = lambda(lambdais)
%
%   1.1.  Input parameters
%
%   o  lambdais : Real matrix
%      Contains the lambda_i's and other informations.
%
%   1.2.  Output parameters
%
%   o  L : Real matrix
%      Contains the lambda_i's. The first two columns contain resp.  the
%      left and the right lambda_i's corresponding to the first segmented
%      part of the signal and so on.
%
%   2.  See also:
%
%   hist, wave2gifs.
%
%   3.  Example:

% Auhtor Khalid Daoudi, June 1997

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------
 
N = length(lambdais);
c = 0 ;
n = 1;

while n <= N,
	lj = lambdais(n) ;
	for i=1:2,
		c = c+1 ;
		for l=1:lj,
			n = n+1 ;
			L(l,c) = lambdais(n);
		end
	end
	n =n+1 ;
end
