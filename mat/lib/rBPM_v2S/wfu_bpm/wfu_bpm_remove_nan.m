function data = wfu_bpm_remove_nan(data)

[M,N] = size(data);

for k = 1:max([M,N])
    
    vol = data{k};
    [M1,N1,No_slices] = size(vol);
    AA = vol(:);
    indx = find(isnan(AA));
    AA(indx) = 0;
    vol = reshape(AA,M1,N1,No_slices);
    data{k} = vol;
end
