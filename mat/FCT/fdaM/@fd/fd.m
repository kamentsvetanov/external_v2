function fdobj = fd(coef, basisobj, fdnames)
%  FD   Creates a functional data object.
%    A functional data object consists of a basis for expanding a functional
%    observation and a set of coefficients defining this expansion.
%    The basis is contained=a 'basis' object; that is, a realization
%    of the 'basis' class.
%
%  Arguments:
%  COEF     ... An array containing coefficient values for the expansion 
%               of each set of function values=terms of a set of basis 
%               functions.
%               If COEF is a three-way array, then the first dimension
%               corresponds to basis functions, the second to replications,
%               and the third to variables.
%               If COEF is a matrix, it is assumed that there is only
%               one variable per replication, and then:
%                 rows    correspond to basis functions
%                 columns correspond to replications
%               If COEF is a vector, it is assumed that there is only one
%               replication and one variable.
%               If COEF is empty, it is left that way.
%  BASISOBJ ... a functional data basis object.  
%               If this argument is missing, a B-spline basis is created
%               with the number of basis functions equal to the size
%               of the first dimension of coef.
%  FDNAMES  ... A cell of length 3 with members containing
%               1. a name for the argument domain, such as 'Time'
%               2. a name for the replications or cases
%               3. a name for the function
%               If this argument is not supplied, the strings
%               'arguments', 'replications' and 'functions' are used 
% 
%  An alternative argument list:
%  The argument COEF can be dropped, so that BASISOBJ is the 
%  leading argument.  In this case, COEF is set to [], an empty
%  array.  For many purposes, and especially for functional parameter
%  objects (fdPar), the coefficient array is either not needed, or
%  supplied later.  
%
%  Returns:
%  FD ... a functional data object

%  last modified 20 July 2006

superiorto('double', 'struct', 'cell', 'char', 'inline', ...
    'basis');

if nargin == 0
    
    %  set up default object if there are no arguments:
    %    a single function with a constant basis and coefficient zero
    
    fdobj.coef     = zeros(1,1);
    fdobj.basisobj = create_constant_basis([0,1]);
    fdnames{1} = 'arguments';
    fdnames{2} = 'replications';
    fdnames{3} = 'functions';
    fdobj.fdnames = fdnames;
    fdobj = class(fdobj, 'fd');
    return;
    
end
    
if strcmp(class(coef), 'double')
    
    %  -----------------  Normal Case: first argument an array  --------
    
    %  set up default coefficient array and basis if necessary
    
    
    %  if leading argument is already an fd object, do nothing
    
    if isa(coef, 'fd')
        fdobj = coef;
        return; 
    end
    
    %  if leading argument is not of class double, send error message
    
    if ~strcmp(class(coef), 'double')
        error('First argument not an array.');
    end
    
    if nargin == 1
        
        %  if no basis input, default to a B-spline basis over [0,1]
        
        if isempty(coef)
            error('Default basis cannot be constructed, COEF is empty.');
        end
        nbasis   = size(coef,1);
        norder   = 4;
        basisobj = create_bspline_basis([0,1], nbasis, norder);   
        warning('A default B-spline basis was created.');
    end
    
    if nargin == 2 || isempty(fdnames)
        %  set up default FDNAMES
        fdnames{1} = 'arguments';
        fdnames{2} = 'replications';
        fdnames{3} = 'functions';
    end
    
elseif strcmp(class(coef), 'basis')
    
    %  --------  Alternative Case: first argument a basis object --------
    
    basisobj = coef;
    coef     = [];
    if nargin == 1 || isempty(fdnames)
        %  set up default FDNAMES
        fdnames{1} = 'arguments';
        fdnames{2} = 'replications';
        fdnames{3} = 'functions';
    end
else
    
    error(['Leading argument is neither of class double or ', ...
            'of class basis.']);
    
end

if ~isempty(coef)
    
    %  check dimensions of coefficient array
    
    coefd = size(coef);
    ndim  = length(coefd);
    if (ndim > 3)
        error('Coefficient array has more than three dimensions.');
    end
end

%  check basisobj

if ~strcmp(class(basisobj), 'basis')
    error('Argument BASISOBJ is not of basis class.');
end

nbasis  = getnbasis(basisobj);
dropind = getdropind(basisobj);
nbasis  = nbasis - length(dropind);

if ~isempty(coef)
    if coefd(1) ~= nbasis
        error(['First dimension of coefficient array is ', ...
                'not equal to number of basis functions.']);
    end
end

%  check fdnames

if ~iscell(fdnames)
    error('FDNAMES not a cell object.');
end

if length(fdnames) > 3
    error('FDNAMES has length greater than 3.');
end

%  fill missing cells with default labels

if length(fdnames) == 2
    fdnames{3} = 'functions';
end    
if length(fdnames) == 1 
    fdnames{2} = 'replications';
    fdnames{3} = 'functions';
end    

%  set up object

fdobj.coef     = coef;
fdobj.basisobj = basisobj;
fdobj.fdnames  = fdnames;

fdobj = class(fdobj, 'fd');

