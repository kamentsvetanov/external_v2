
a = dir('/usr/local/fsl/etc/luts/*.lut');

clf
for i=1:length(a)
%%
fname = ['/usr/local/fsl/etc/luts/' a(i).name];
fid = fopen(fname);
lut = zeros(1,3,1);
while 1
    s = fgetl(fid);
    if isequal(s,-1), break; end
    if isequal(strfind(s, '<-color'),1)
        lut = [lut; str2num(regexprep(s, '[a-z<>{}-]',''))];
    end
end
fclose(fid)

%plot(fliplr(lut))
subplot(3, ceil(length(a)/3), i)
imagesc(permute(lut,[3 1 2]))
title(fname)

%%
end