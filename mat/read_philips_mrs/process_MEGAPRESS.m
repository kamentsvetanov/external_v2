clear all

% MEGAPRESS 3x3
%root = '20111011_1550_11_2_raw_act';

% MEGAPRESS 2x2
root = 'kt12_07_6_2_raw_act';

max_ppm = 4.0;
min_ppm = 0.5;
ref = 4.7;
zfill = 1;
lambda = 10;

spar = [ root '.SPAR' ];
sdat = [ root '.SDAT' ];
[time_sig, paras] = read_philips(spar, sdat);
data_rows = reshape(time_sig, paras.samples, paras.rows);

t = 0:1/paras.fs:(paras.samples/paras.fs-1/paras.fs); % t for time
t_zfill = 0:1/paras.fs:(paras.samples*zfill/paras.fs-1/paras.fs); % t for time
exp_fn = exp(-lambda*t); % exponential function for line broadening
freq_scale = (-paras.fs/2:paras.fs/(paras.samples*zfill):paras.fs/2 ... 
    - paras.fs/(paras.samples*zfill)).';
ppm_scale = (-freq_scale/paras.t_freq)*10^6+ref;

% take odd rows and combine
edit_on = data_rows(:,1:2:paras.rows);
edit_on_td_sum = sum(edit_on,2);

% apply exp fn
%edit_on_td_sum = edit_on_td_sum.*exp_fn.';
edit_on_fd = real(fftshift(fft(edit_on_td_sum)));

% take even rows and combine
edit_off = data_rows(:,2:2:paras.rows);
edit_off_td_sum = sum(edit_off,2);

% apply exp fn
%edit_off_td_sum = edit_off_td_sum.*exp_fn.';
edit_off_fd = real(fftshift(fft(edit_off_td_sum)));

% combine edit on and edit off
combined_td = edit_on_td_sum + edit_off_td_sum;

combined_td = hsvd_remove(combined_td, paras.fs, 30);

combined_td = combined_td.*exp_fn.'*exp(i*0*pi/180);

combined_fd = real(fftshift(fft(combined_td)));

plot(ppm_scale, combined_fd);
xlabel('Frequency (ppm)');
ylabel('Intensity (au)');
set(gca, 'xlim', [0.5 6.0]);
set(gca,'xDir','reverse');
print('-dpng','-r500','MEGAPRESS_GLTH_2x2.png');
