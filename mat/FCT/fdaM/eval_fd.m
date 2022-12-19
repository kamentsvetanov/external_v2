function evalarray = eval_fd(evalarg, fdobj, Lfdobj)
%  EVAL_FD evaluates a functional data observation at argument 
%  values EVALARG.
%
%  LFDOBJ is a functional data object defining the order m 
%  HOMOGENEOUS linear differential operator of the form
%  Lx(t) = w_0(t) x(t) + ... + w_{m-1}(t) D^{m-1}x(t) + 
%          \exp[w_m(t)] D^m x(t) + ...
%
%  Arguments:
%  EVALARG ... A vector of values at which all functions are to 
%              evaluated.
%  FDOBJ   ... Functional data object
%  LFDOBJ  ... A linear differential operator object
%              applied to the functions that are evaluated.
%
%  Note that the first two arguments may be interchanged.
%
%  Returns:  An array of function values corresponding 
%              to the evaluation arguments in EVALARG

%  Last modified 2 December 2006

if nargin < 2
    error('Number of arguments is less than 2.');
end

%  check LFDOBJ and convert an integer to Lfd if needed.

if nargin < 3 
    %  set default LFDOBJ to 0
    Lfdobj = int2Lfd(0); 
else
    %  check LFDOBJ
    if isnumeric(Lfdobj)
        % if integer, check and convert to Lfd
        nderiv = Lfdobj;
        if nderiv ~= round(Lfdobj)
            error('LFDOBJ numeric but not an integer.');
        end
        if nderiv < 0
            error('LFDOBJ an integer but negative.');
        end
        Lfdobj = int2Lfd(nderiv);
    end
end

%  Exchange the first two arguments if the first is an FD object
%    and the second numeric

if isnumeric(fdobj) && isa_fd(evalarg)
    temp    = fdobj;
    fdobj   = evalarg;
    evalarg = temp;
end

%  check EVALARG

sizeevalarg = size(evalarg);
if sizeevalarg(1) > 1 && sizeevalarg(2) > 1
    error('Argument EVALARG is not a vector.');
end
evalarg = evalarg(:);

%  check FDOBJ

if ~isa_fd(fdobj)
    error('Argument FD is not a functional data object.');
end

if ~(isa_Lfd(Lfdobj))
    error('LFD is not linear differential operator object.');
end

%  Extract information about the basis

basisobj = getbasis(fdobj);
rangeval = getbasisrange(basisobj);

%  check that arguments are within range

evaldim = size(evalarg);
temp    = reshape(evalarg,prod(evaldim),1);
temp    = temp(~(isnan(temp)));
EPS     = 1e-14;
if min(temp) < rangeval(1) - EPS || max(temp) > rangeval(2) + EPS     
    warning('Wid1:range', ...
            ['Values in argument EVALARG are outside of ', ...
             'permitted range, and will be ignored.']);
    disp(['Min and max args:             ', ...
         num2str([min(temp), max(temp)])])
    disp(['Min and max permitted values: ', ...
         num2str([rangeval(1), rangeval(2)])])
end

%  get maximum number of evaluation values

n = evaldim(1);

%  Set up coefficient array for FD

coef  = getcoef(fdobj);
coefd = size(coef);
ndim  = length(coefd);
if ndim <= 1
    nrep = 1;
else
    nrep = coefd(2);
end
if ndim <= 2
    nvar = 1;
else
    nvar = coefd(3);
end

%  Set up array for function values

if ndim <= 2
    evalarray = zeros(n,nrep);
else
    evalarray = zeros(n,nrep,nvar);
end

%  Case where EVALARG is a vector of values to be used for all curves

if evaldim(2) == 1

    evalarg(evalarg < rangeval(1)-1e-10) = NaN;
    evalarg(evalarg > rangeval(2)+1e-10) = NaN;
    basismat = eval_basis(evalarg, basisobj, Lfdobj);

    %  evaluate the functions at arguments in EVALARG

    if ndim <= 2
        evalarray = basismat*coef;
    else
        for ivar = 1:nvar
            evalarray(:,:,ivar) = basismat*coef(:,:,ivar);
        end
    end
   
else
    
    %  case of evaluation values varying from curve to curve
    
    for i = 1:nrep
        evalargi = evalarg(:,i);
        if all(isnan(evalargi))
            error(['All values are NaN for replication ',num2str(i)]);
        end
        
        index = find(~isnan(evalargi)       || ...
                     evalargi < rangeval(1) || ...
        evalargi > rangeval(2));
        evalargi = evalargi(index);
        basismat = eval_basis(evalargi, basisobj, Lfdobj);
        
        %  evaluate the functions at arguments in EVALARG
        
        if ndim == 2
            evalarray(:,i) = NaN;
            evalarray(index, i) = basismat*coef(:,i);
        end
        if ndim == 3
            for ivar = 1:nvar
                evalarray(:,i,nvar) = NaN;
                evalarray(index,i,ivar) = basismat*coef(:,i,ivar);
            end
        end        
    end
end


