function  [a_hat, b_hat] = hexposc(signal,winvector,binwidth, est_type)
%----------------------------------------------------------------------------------------
% FILE:		hexposc.m
% DESCRIPTION:	This file produces an estimate of the pointwise holder exponent
%		at each point in a signal. 
%		signal - 1D signal
%		winvector - list of window widths and subsamplings in the following
%					format:
%								window1		subsamp1
%								window2		subsamp2
%									...			...
%
%					for example see TestRegSeq, it should work right away.
%					Note that widths are ball DIAMETERS and that subsamplings
%					are constrained so that (window_width-1)/(subsampling-1)
%					be an integer.  
%
%		binwidth - since signal will be normalized to [0,1], binwidths in
%					in this range are required...0.001 is reasonable
%		est_type -	right now, only 3 types of estimation types are supported
%					'CgivenD' straightforward conditional estimation
%					'UniOscPri'  Bayesian estimation assuming uniformly distributed
%								 oscillation
%					'LocTimPri' Bayesian estimation assuming that the appropriate prior
%								prior is the local time function of the oscillation of
%								the signal

% MODIFICATIONS:	1)	Completed	19 Jun 99	JCW
%				NOTES:	 i) more error checking, please
%						ii) more could be done in C
%					   iii) may want to choose to report bin or index
%						iv) transposing maxArg every time is time consuming
%							should build by rows and then transpose once
%						 v) Significant Prior section should be generalized
%						vi) Considerable redesign is required for modularity
%							getting holder function this way is clumsy...
%						vii)MUST OFFER REGRESSION CHOICES
%						viii) Using Ceil when adjusting oscillation seems ad hoc
%----------------------------------------------------------------------------------------

% Author Jon C. Weil, Cambridge CB1 2NU, June 1999

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

tic

	%if( ~strcmp(est_type,'CgivenD') | ~strcmp(est_type,'UniOscPri') )
	%	fl_warning('getBayesDecTables:  Bad estimation type.');
	%	return;
	%end;
	
	if( strcmp(est_type,'CgivenD') )
		conditionDim='row';
		maxDim=1;
		insignificantPrior=1;
	elseif( strcmp(est_type,'UniOscPri') )
		conditionDim='col';
		maxDim=1;
		insignificantPrior=1;
	elseif( strcmp(est_type,'LocTimPri') )
	        conditionDim='col';
		maxDim=1;
		insignificantPrior=0;
	else
		fl_warning('getBayesDecTables:  Bad oscillation estimation type.');
		return;
	end;
	
	% NORMALIZE SIGNAL
	nsignal=normsig(signal);	
	% GET SIZES
	[numwins numcols]= size(winvector);
	numbins=ceil(1/binwidth);
	szsignal=max(size(signal));
	
	% GET MEMORY
	hfunc = zeros(szsignal,numwins);
	maxArg = zeros(numbins,1);
	CondOsc = zeros(numbins,numbins);
	ltdensMat = zeros(numbins,numbins);
	ltdens = zeros(numbins,1);
	
	% ( memory FOR VERIFICATION )
	% RgCbayesTable=zeros(numbins,numwins);
	% CgRbayesTable=zeros(numbins,numwins);
	
	% RgivenC=zeros(numbins,1);
	% CgivenR=zeros(numbins,1);
	
	if( insignificantPrior)  % NOT SO MUCH WORK TO DO
	
	     % LOOP THROUGH WINDOW VECTOR
	     for winx=1:numwins
		    winwidth=winvector(winx,1);
		    subsamp=winvector(winx,2);
		
		    % GET OSCILLATION CONDITIONED UNDER DECIMATION
	            [CondOsc SigOsc] = getDecOscCon(nsignal,winwidth,subsamp,binwidth);
	   	        
	        
	            % COMPUTE PROBABILITY
	
	    [AA maxArg] = max( conditionMAT(CondOsc,conditionDim),[], maxDim );	
		    % REPORT CENTER OF BIN
		    maxArg = (maxArg' * binwidth) - (binwidth/2.0);
		    
		    % ADJUST ESTIMATE OF OSCILLATION (CLUMSILY)
		    halfWidth=(winwidth-1)/2;
		    % SIGOSC IS ONE TOO LARGE, I IGNORE THE LAST POINT
		    for(i=halfWidth+1:szsignal-halfWidth-1)
		        hfunc(i ,winx) = maxArg(  ceil( SigOsc(i-halfWidth)/binwidth )  );
		    end;
		
		    % ( FOR VERIFICATION )
		    % [AA CgivenR] = max( conditionMAT(CondOsc,'row'),[], 2 );
% MIND THE TWO
		    % [AA RgivenC] = max( conditionMAT(CondOsc,'col'),[], 1 );
		    % CgRbTable(:,winx)=CgivenR; %*binwidth - (binwidth/2.0);
		    % RgCbTable(:,winx)=RgivenC'; %*binwidth - (binwidth/2.0);
		
	     end
	   
	else
	     
	     for winx=1:numwins			        % MUST GET A MATRIX EVERY ITERATION
	     	    winwidth=winvector(winx,1);
	     	    subsamp=winvector(winx,2);
	     	    
	     	    % GET OSCILLATION CONDITIONED UNDER DECIMATION
	     	    [CondOsc SigOsc] = getDecOscCon(nsignal,winwidth,subsamp,binwidth);
	     	    
	     	    % GET PRIOR (THIS WILL BE GENERALIZED)
	     	    dens = ltdensity( SigOsc, binwidth )';  % NOTE TRANSPOSE	
	     	    % CREATE MATRIX FOR POINTWISE MULTIPLICATION OF PRIOR DENSITY     	  
	     	    ltdensMat = dens( ones( numbins,1 ), : );
	     	    
	     	    % COMPUTE PROBABILITY
	     	    CondOsc = conditionMAT(CondOsc, conditionDim) .* ltdensMat;
	     	    [AA maxArg] = max( CondOsc ,[],maxDim );
	     	    
	     	    % REPORT CENTER OF BIN
	     	    maxArg = (maxArg' * binwidth) - (binwidth/2.0);
	     	    % ADJUST ESTIMATE OF OSCILLATION (CLUMSILY)
	     	    halfWidth=(winwidth-1)/2;
	     	    % SIGOSC IS ONE TOO LARGE, I IGNORE THE LAST POINT
 	    		for(i= halfWidth+1:szsignal-halfWidth-1)
		        hfunc(i ,winx) = maxArg(  ceil( SigOsc(i-halfWidth)/binwidth )  );
		    end;
		    	     	    
	     end
						
	end;	% END IF INSIGNIFICANT PRIOR
	
	% ESTIMATE POINTWISE HOLDER FUNCTION
	%  (Don't know if monolr is vectorized) AND i appear to be using it incorrectly.
	
	halfWidth=((winvector(numwins,1)-1)/2 ) + 1;
	for(i=halfWidth:szsignal-halfWidth-1)
	  [a_hat(i),b_hat(i)]=monolr(log( hfunc(i,:) ),log( winvector(:,1) ));
	end
	
toc

%----------------------------------------------------------------------------------------
% NORMALIZE VECTOR SO THAT IT LIES IN [0,1]
function  y =   normsig(x)
	mxx=max(x);
	mnx=min(x);
	dfx=mxx-mnx;
	y=(x-mnx)/dfx;


%----------------------------------------------------------------------------------------
% CONDITION MATRIX ALONG ROWS OR COLUMNS
function m2 =  conditionMAT(m1,normdim)
	switch(normdim)
		case 'row'
			% GET SUMS
			k=sum(m1');
			% MAKE SUITABLE MATRIX
			k1=k( ones(size(m1,1),1), : )';

	   	case 'col'
	   		% GET SUMS
        		k=sum(m1);
        		% MAKE SUITABLE MATRIX
	        	k1=k(ones(size(m1,1),1) , :);
	end
	
	% THOUGH WEIRD, THIS IS OK - ZERO SUM MEANS NO COUNTS! 
	% NEED TO SUPPRESS DIVIDE BY ZERO ERROR
	k1(k1==0)=1;
	% DIVIDE
	m2=m1./k1;
	
	
%----------------------------------------------------------------------------------------
% GET LOCAL TIME DENSITY	
function dens  = ltdensity(signalosc,binwidth)

	% GET SIZE
	[r,c]= size(signalosc);
	osclength=r;
	dens=zeros(ceil(1/binwidth),1);

	% GET FIRST POINT
	bs1 = round( signalosc(1)/binwidth );
	
	% LOOP THROUGH SIG OSC BINNING OSC VALUES
	for i=1:osclength-1
 		bs2 = round( signalosc(i+1)/binwidth );
 		
 		% GETTING DIFF OF SUCCEEDING VALS GIVES SLOPE (X STEP=1) 
 		diff =  abs( signalosc(i+1) - signalosc(i) );
		if(diff ~= 0 & (bs1*bs2) ~=0)
			% RECIPROCAL
	   		diff= 1/diff;
	   		% INCREMENT HISTOGRAM FOR EACH BIN BETWEEN OSC VALS
	 		for j=bs1:bs2
 		    	dens( j ) =  dens( j ) +  diff;
	 		end;
	 	end;
	 	bs1 = bs2;
	 	   
	end;
	% NORMALIZE
	dens=dens/sum(dens);

%----------------------------------------------------------------------------------------
% MAKE A MATRIX FROM A VECTOR OF INDICES (for verification)
function mA = makeMAT(A)
	sz=max(size(A));
	for i=1:sz 
	   mA( A(i),i )=1; 
	end	
	
	
	