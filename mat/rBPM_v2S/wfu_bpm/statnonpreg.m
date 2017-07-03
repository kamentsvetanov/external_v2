function [ beta, stats ] = statnonpreg( x,y,B,C,PiCond )

%-Parameters & Initialisation
%=======================================================================
%-Work out degrees of freedom
%-----------------------------------------------------------------------
q       = size([B C],1);		%-# observations
p       = size([B C],2);		%-# predictors
r       = rank([B C]);		%-Model degrees of freedom
df      = q - r;			%-Residual degrees of freedom
nPerm   = size(PiCond,1);		%-# permutations

%=======================================================================
% - C O R R E C T   P E R M U T A T I O N
%=======================================================================
% Work out correct permuation completely. Separating the first
% permutation simplifies the permutation loop (fewer conditionals) and
% allows determination of pseudo-t threshold when saving supratheshold
% statistics.

perm = 1;

	%-Estimate parameters and sum of squares due to error.
	% Use pseudo inverse rather than BETA=inv(D'*D)*D'*X for 
	% D = DesMtx, to allow for non-unique designs. See matlab help.
	%-----------------------------------------------------------------
	BETA  = pinv([B C])*y;
	ResSS = sum((y - [B C]*BETA).^2);
    beta = BETA;
	
	%-Compute t-statistics for specified compounds of parameters
	%-----------------------------------------------------------
	Co     = [1 0];
	  % t, as usual
	  T = Co*BETA./sqrt((ResSS*(Co*pinv([B C]'*[B C])*Co'))/df);
          
  T0 = T;
  nPtmp = 1;
   % Save everything
   stats.res = ResSS;
   stats.t = T;


%=======================================================================
% - C O M P U T E   F O R   P E R M U T A T I O N S
%=======================================================================

	%-Loop over permutations
	%-----------------------------------------------------------------
	for perm = 2:nPerm
	    
	    %-Rebuild H C for current permuation
	    %-----------------------------------------------------------
	    HC = PiCond(perm,:) - mean(x);
        HC = HC(:);
	    
	    %-Estimate parameters and sum of squares due to error
	    %-Use pseudo inverse rather than BETA=inv(D'*D)*D'*X
	    % for D = DesMtx, to allow for non-unique designs. 
	    % See matlab help.
	    %-----------------------------------------------------------
	    BETA  = pinv([B HC])*y;
	    ResSS = sum((y - [B HC]*BETA).^2);
	    	    
	    %-Compute t-statistics for specified contrast of parameters
	    %-----------------------------------------------------------
	    Co     = [1 0];
	      % t, as usual
	      T = Co*BETA./sqrt((ResSS*(Co*pinv([B HC]'*[B HC])*Co'))/df);
	    	   
	    
	    %-Update nonparametric P-value
	    %-----------------------------------------------------------
	    if (perm==1)
	      T0 = T;
	      nPtmp = 1;
        else
          nPtmp = nPtmp + (T>=T0);
        end

	end 	% (for perm = StartPerm:nPerm) - Perm loop
    pval = nPtmp/nPerm;
    stats.p = pval;
end

