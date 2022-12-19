% OUT = MAKESIZE(IN, SIZE)
%  Resizes IN so that it matches the size SIZE.  Normally
%  this is done by REPMATing IN an integer number of times in 
%  each dimension.  It also shrinks matrices if they e.g. have 
%  many identical rows or columns.

function out = makesize(in, sm)

% Copyright 2007-09, Adrian Groves, FMRIB Centre, Oxford
%  adriang@fmrib.ox.ac.uk

si = size(in);
ndim = max(length(si), length(sm));
si(end+1:ndim) = 1;
sm(end+1:ndim) = 1;

% Find dimensions to condense along
for i = find(sm==1 & si>1)
    % Check it's okay (all identical)
    tmp = desomething(in, i, 'max'); % could use mean, but that introduces rounding errors.
    if(any(tmp(:)))
        si
        sm
        ndim
        error 'Invalid dims?'
    end
    
    % Mess around to crush an arbitrary dimension...
    clear S
    S.type = '()';
    S.subs = repmat({':'}, [ndim 1]);
    S.subs{i} = 1;
    in = subsref(in, S);
    si(i) = 1;
end

srat = sm ./ si;
srat(~isfinite(srat) & (sm==0)) = 1;


if any(mod(srat,1))
    si
    sm
    srat
    
%    if any(srat < 1)
%        error('Currently matchsize can''t shrink matrices.. but that''s a good idea, implement it!  (Should check that all merged cells are identical!)')
%    end
    error('Incompatible sizes!')
end

out = repmat(in, srat);