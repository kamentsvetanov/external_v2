function legs = nicer_pathnames(folders, exclude)

waschar = ischar(folders);
if waschar
    folders = {folders}; 
end

if nargin<2 || isempty(exclude)
    exclude = {};
elseif ischar(exclude)
    exclude = {exclude};
end

for i=1:numel(folders)
    str = folders{i};
   
    if (~isempty(str))
        if (str(end) == '/'), str(end) = []; end;
        str(1:find(str=='/',1,'last')) = [];
       
        for e = 1:length(exclude)
            str = regexprep(str, exclude{1}, '');
        end
    
        str = regexprep(str, '_out','');
        str = regexprep(str, '_basic','');
        str = regexprep(str, '_prior', '_p');
    
        str = regexprep(str, '_', '\\\_');
    end    
    legs{i} = str;
end

if waschar
    assert(numel(legs)==1)
    legs = legs{1};
end