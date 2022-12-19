% [M, weight] = flica_reorder(M, ignoreExtraFields)
%   Reorder components and standardize model output:
%   - Sorting components by total energy ("weight")
%   - Flipping polarities, so most energy is positive
%   - Deleting empty components
%   - Force scaling factor W=1, and move scale into X
%   - Force scaling of H so that each subject-course is RMS=1.
%   For safety, this will raise a warning or error if there's an
%   unrecognized field in M (should it be re-ordered/re-scaled or not?)
%   ignoreExtraFields = false will issue a warning for each field (default).
%   ignoreExtraFields = true will issue an error if there's an unrecognized field
%   ignoreExtraFields = {'name1','name2'} will silently pass these fields
%   through unchanged, and raise an error on any other unrecognized ones.
function [M, weight] = flica_reorder(M, targetH, ignoreExtraFields)

K = length(M.X);
R = size(M.H,2);

ignoreFieldsList = {'q','F','F_history','lambda','DD','opts','toc_setup','toc_history'};

if nargin<3 || isempty(ignoreExtraFields)
    ignoreExtraFields = true; % Default to permissive behaviour, with warning
elseif islogical(ignoreExtraFields) && numel(ignoreExtraFields)==1
    % nop: ignoreExtraFields = ignoreExtraFields
elseif iscellstr(ignoreExtraFields)
    ignoreFieldsList = [ignoreFieldsList ignoreExtraFields];
    ignoreExtraFields = false; % raise an error if unrecognized.
end
    
if nargin<2, targetH = []; end

%% Find the best order
Xcat = [];
for k=1:K
    Xcat = [Xcat; ...
        M.X{k} * diag(M.W{k}.*sqrt( M.H.^2 * makesize(M.lambda{k},[R 1]) * M.DD(k))')]; %#ok<AGROW>
end
weight = sum(Xcat.^2,1);
if isempty(targetH)
    [weight,order] = sort(weight, 'descend');
    order(weight==0) = [];
    weight(weight==0) = [];
    polarity = sign(sum(Xcat.^2.*(Xcat>0))-sum(Xcat.^2.*(Xcat<0)));
    polarity = polarity(order);
else
    if size(targetH,1) > size(M.H,1)
        warning('Target has more components than model -- some might be skipped!')
    end
    pc = sortrows(paircomponents(targetH', M.H'));
    order = pc(:,2);
    weight = weight(order);
    polarity = sign(pc(:,3));
    polarity(isnan(polarity)|polarity==0) = 1;
end

assert(all(weight>0) && all(abs(polarity)==1))

%% Do some tidy rescaling as well, while we're at it
% H should have unit RMS
rescaleH = polarity./rms(M.H(order,:),2)';

for k=1:K
    % W should all equal 1
    rescaleW{k} = 1./M.W{k}(:,order);
    % X should take up the remaining scaling
    rescaleX{k} = 1./rescaleH./rescaleW{k};

    assertalmostequal(rescaleH.*rescaleW{k}.*rescaleX{k}, ones(size(polarity)));
end

%% Apply the reordering & flipping to each element

for f = fieldnames(M)' % Loop over fields in M
    fn = f{:};
    switch(fn)
        case 'H' % first dimension needs rescaleH
            M.H = diag(rescaleH)*M.H(order,:);
            
        case 'H_PCs' % reorder dim2
            M.H_PCs = M.H_PCs(:,order);
            
        case 'W' % second dimension needs rescaleW{k}
            for k=1:K
                M.W{k} = M.W{k}(:,order)*diag(rescaleW{k});
            end
            
        case {'X','mu'} % second dimension needs rescaleX{k}
            for k=1:K
                M.(fn){k} = M.(fn){k}(:,order)*diag(rescaleX{k});
            end            

        case {'X','Xq','mu'} % second dimension needs rescaleX{k}; apply to each slice.
            for k=1:K
                M.(fn){k} = apply3(@(Z) Z*diag(rescaleX{k}), M.(fn){k}(:,order));
            end            
            
            
        case 'beta' % second dimension needs rescaleX{k}^-2
            for k=1:K
                M.(fn){k} = M.(fn){k}(:,order) * diag(rescaleX{k}.^-2);
            end
           
        case {'pi','pi_mean'} % reorder dim2 of a cell
            for k=1:K
                M.(fn){k} = M.(fn){k}(:,order);
            end
            
        case ignoreFieldsList % nop
            % Pass through unchanged
            
        otherwise
            if ignoreExtraFields
                warning('Unknown field %s, passing through unchanged', fn)
            else
                error('Unknown field %s', fn)
            end
    end
end

assert(rms([M.W{:}]-1) < 1e-12)
M.W = [];  % I.e. it's been removed, you can just use Y{k} ~ X{k}*H


