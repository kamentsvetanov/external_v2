function y_new = hsvd_remove(y, fs, freq)

[frequencies_orig, dampings_orig, norm_basis_orig, ahat_orig] = hsvd(y, fs);
keep_index = [ frequencies_orig < freq ];
frequencies = frequencies_orig(find(keep_index));
dampings = dampings_orig(find(keep_index));
norm_basis = norm_basis_orig(find(keep_index));
ahat = ahat_orig(find(keep_index));
t = (0:1/fs:(length(y)-1)*1/fs);
norm_basis = exp(t.'*(dampings.'+j*2*pi*frequencies.'));
basis = norm_basis.*repmat(ahat,1,length(y)).';
y_new = y - norm_basis*ahat;