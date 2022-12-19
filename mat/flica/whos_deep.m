% W = WHOS_DEEP(S)
% or just WHOS_DEEP(WHOS) to look at the current workspace
%   Figure out what's taking up all the space in a structure or cell array
%
% Alternatively, use whos_deep_currentworkspace to look at the current
% workspace is more detail.

function [W,total] = whos_deep(S, prefix, maxdepth, flagtype)
if nargin<1, error 'Usage: whos_deep(object) to look at memory usage in an object, or whos_deep(whos) to look at the whole current workspace.'; end
if nargin<2, prefix=''; end
if nargin<3, maxdepth=inf; end
if nargin<4, flagtype={}; end

W = [];

if isfield(S, 'bytes')
    disp 'Called as whos_deep(whos)... different from normal call'
    
    [~,order] = sort([S.bytes]);
    S=S(order);
    for i=1:length(S)
        fprintf('%12d: %s\n', S(i).bytes, S(i).name);
    end
    fprintf('---------------\nTOTAL: %d bytes\n', sum([S.bytes]));
    fprintf('     = %.1f kB\n', sum([S.bytes])/1000);
    fprintf('     = %.1f MB\n', sum([S.bytes])/1e6);
    clear W total
    return
    
elseif isstruct(S) && maxdepth>0
    fs = fieldnames(S);
    for i=1:length(fs)
        item = S.(fs{i});
        details = whos_deep(item, [prefix '.' fs{i}], maxdepth-1, flagtype);
        W = [W;details];
    end
elseif iscell(S) && maxdepth>0
    for i=1:numel(S)
        item = S{i};
        details = whos_deep(item, [prefix '{' num2str(i) '}'], maxdepth-1, flagtype);
        W = [W;details];
    end
else
    %W.name = prefix;
    details = whos('S');
    %W.size = details.bytes; 
    W = {prefix details.bytes};
end

total = [W{:,2}];
[~,order] = sort(total); %,'descend');
W = W(order,:);
total = sum(total);

%if maxdepth >= 0 && (isfinite(maxdepth) || total > 1e6), fprintf('% 12i : %s\n', total, prefix); end
if total > 1e6, fprintf('% 12i : %s\n', total, prefix); end
if any(strcmp(class(S), flagtype)), fprintf('%s is of type %s!\n',prefix,class(S)); end
return

    