% (c) 2012, Ameera X. Patel, University of Cambridge
% Temporary function: this will be redundant for the next release.

function [] = reformat(input,frames)

file=load(input);
nf=str2double(frames);
pref=strtok(input,'.');

if size(file,2)==nf;
    file=file';
end

if size(file,1)==1 % in case DVARS / FD are in wrong orientation or csv
    file=file';
end

if size(file,2)==3 % in case coordinates are in wrong orientation or csv
    file=file';
end

if size(file,1)==6 % in case motion parameters are csv
    file=file';
end

dlmwrite(sprintf('%s.txt',pref),file,' ')

end