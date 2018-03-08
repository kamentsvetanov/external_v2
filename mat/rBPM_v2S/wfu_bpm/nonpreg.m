function varargout = nonpreg( x, y )

nSubj = length(y);

%-Work out how many perms, and ask about approximate tests
%-----------------------------------------------------------------------
%-NB: n! == gamma(n+1)
nPiCond = gamma(nSubj+1);
%     bAproxTst = spm_input(sprintf('%d Perms. Use approx. test?',nPiCond),...
% 							'+1','y/n')=='y';
%     if bAproxTst
%         tmp = 0;
%         while ((tmp>nPiCond) | (tmp==0) )
%         tmp = spm_input(sprintf('# perms. to use? (Max %d)',nPiCond),'+0');
%         tmp = floor(max([0,tmp]));
%         end
%         if (tmp==nPiCond), bAproxTst=0; else, nPiCond=tmp; end
%     end
%Use approx. test 1000
bAproxTst=1;

%-Compute permutations of conditions
%=======================================================================
if (nPiCond<=500) % 0.01 level, 1000times
    bAproxTst=0; 
else
    nPiCond=500; 
end

if bAproxTst
	%-Approximate test :
	% Build up random subset of all (within nSubj) permutations
	%===============================================================
	rand('seed',sum(100*clock))	%-Initialise random number generator
	PiCond      = zeros(nPiCond,nSubj);
	PiCond(1,:) = 1+rem([0:nSubj-1],nSubj);
	for i = 2:nPiCond
		%-Generate a new random permutation - see randperm
		[null,p] = sort(rand(nSubj,1)); p = p(:)';
		%-Check it's not already in PiCond
		while any(all((meshgrid(p,1:i-1)==PiCond(1:i-1,:))'))
			[null,p] = sort(rand(nSubj,1)); p = p(:)';
		end
		PiCond(i,:) = p;
	end
	clear p

else
	%-Full permutation test :
	% Build up exhaustive matrix of permutations
	%===============================================================
	%-Compute permutations for a single exchangability block
	%---------------------------------------------------------------
	%-Initialise XblkPiCond & remaining numbers
	XblkPiCond = [];
	lef = [1:nSubj]';
	%-Loop through numbers left to add to permutations, accumulating PiCond
	for i = nSubj:-1:1
		%-Expand XblkPiCond & lef
		tmp = round(exp(gammaln(nSubj+1)-gammaln(i+1)));
		Exp = meshgrid(1:tmp,1:i); Exp = Exp(:)';
		if ~isempty(XblkPiCond), XblkPiCond = XblkPiCond(:,Exp); end
		lef = lef(:,Exp);
		%-Work out sampling for lef
		tmp1 = round(exp(gammaln(nSubj+1)-gammaln(i+1)));
		tmp2 = round(exp(gammaln(nSubj+1)-gammaln(i)));
		sam = 1+rem(0:i*tmp1-1,i) + ([1:tmp2]-1)*i;
		%-Add samplings from lef to XblkPiCond
		XblkPiCond   = [XblkPiCond; lef(sam)];
		%-Delete sampled items from lef & condition size
		lef(sam) = [];
		tmp = round(exp(gammaln(nSubj+1)-gammaln((i-1)+1)));
		lef = reshape(lef,(i-1),tmp);
		%NB:gamma(nSubj+1)/gamma((i-1)+1) == size(XblkPiCond,2);
	end
	clear lef Exp sam i
	%-Reorientate so permutations are in rows
	XblkPiCond = XblkPiCond';
	PiCond=XblkPiCond;
end

%-Check, condition and randomise PiCond
%-----------------------------------------------------------------------
%-Check PiConds sum within Xblks to sum to 1
if ~all(all(sum(PiCond,2)== (nSubj+1)*nSubj/2 ))
	error('Invalid PiCond computed!'), end
%-Convert to full permutations from permutations within blocks
nPiCond = size(PiCond,1);
%-Randomise order of PiConds (except first) to allow interim analysis
rand('seed',sum(100*clock))	%-Initialise random number generator
PiCond=[PiCond(1,:);PiCond(randperm(nPiCond-1)+1,:)];
%-Check first permutation is null permutation
if ~all(PiCond(1,:)==[1:nSubj])
	error('PiCond(1,:)~=[1:nSubj]'); end


%-Covariate partition & Form for HC computation at permutation perm
C       = x - mean(x);
%-Include constant term in block partition 
B=ones(nSubj,1); Bnames='Const';

varargout=cell(1,max(1,nargout));
[varargout{:}] = statnonpreg(x,y,B,C,PiCond);
end

