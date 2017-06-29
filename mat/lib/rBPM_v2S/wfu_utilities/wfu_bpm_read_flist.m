function file_names = wfu_bpm_read_flist(flist_name)
%_______________________________________________________________________
%   This function reads the content of the flists files
%_______________________________________________________________________
%  Input Parameters
% flist_name  - path and name of the flist file
%_______________________________________________________________________
% Output Parameters
% file_names  - An array containing the paths and file names contained in
%               the flist
%_______________________________________________________________________


file_names = [];
filenamelist = checkflist(flist_name);
n = length(filenamelist);
for i = 1:n
    file_names = strvcat(file_names, filenamelist{i});
end

function filenamelist = checkflist(flist_name)
%
% read the file names into a cell array
%
if ~exist(flist_name, 'file')
    error(['Flist ' flist_name ' does not exist.']);
end
%
% if the first line is numeric, read that many file names;
% otherwise, treat the first line as the first file name
%
nstr = textread(flist_name, '%s', 1);
n = str2num(nstr{1});
if isempty(n)
    filenamelist = textread(flist_name, '%s', 'delimiter', '\n', 'whitespace', '', 'headerlines', 0);
    n = length(filenamelist);
else
    filenamelist = textread(flist_name, '%s', n, 'delimiter', '\n', 'whitespace', '', 'headerlines', 1);
    m = length(filenamelist);
%
% report an error if more lines are requested than exist in the file
%
    if m < n
        error(sprintf('# lines requested (%d) > # lines present (%d) in flist %s', n, m, flist_name));
    end
end
%
% remove trailing blanks from all file names;
% allow a special case of file name path relative to flist
%
for i = 1:n
    filenamelist{i} = deblank(filenamelist{i});
    if strncmp(filenamelist{i}, './', 2) | strncmp(filenamelist{i}, '.\', 2)
        filenamelist{i} = fullfile(fileparts(flist_name), filenamelist{i}(3:end));
    end
end
%
% check for existence of each file name in the list and for duplicates
%
for i = 1:n
%
% report an error if a file in the flist does not exist
%
    if ~exist(filenamelist{i}, 'file')
        error(sprintf('File name\n\t*%s*\nin flist\n\t*%s*\ndoes not exist.', filenamelist{i}, flist_name));
    end
    for j = 1:n
        if i ~= j
%
% report an error if there is a duplicate in the flist
%
            if strcmp(filenamelist{i}, filenamelist{j})
                error(sprintf('Duplicate file name\n\t*%s*\nin flist\n\t*%s*', filenamelist{i}, flist_name));
            end
        end
    end
end
