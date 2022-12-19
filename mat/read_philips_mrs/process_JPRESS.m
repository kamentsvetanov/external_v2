clear all

% JSTEAM
%root = '20111011_1550_9_1_raw_act';
%f1_fs = (1/3e-3);

% JPRESS
%root = 'jPress_PAC_TRHEAD';
%f1_fs = (1/5e-3);

% JPRESS
root = '20111021_1600_15_1_raw_act';
f1_fs = (1/5e-3);

% JPRESS2
%root = '20111021_1600_15_1_raw_act';
%f1_fs = (1/2e-3);

max_ppm = 4.0;
min_ppm = 0.5;
ref = 4.7;
zfill_f1 = 1;
zfill_f2 = 1;

spar = [ root '.SPAR'];
sdat = [ root '.SDAT'];
[time_sig, paras] = read_philips(spar, sdat);
time_sig = reshape(time_sig, paras.samples, paras.rows);

t = 0:1/paras.fs:(paras.samples/paras.fs-1/paras.fs); % t for time
t_zfill = 0:1/paras.fs:(paras.samples*zfill_f2/paras.fs-1/paras.fs); % t for time

freq_scale = (-paras.fs/2:paras.fs/(paras.samples*zfill_f2):paras.fs/2 ... 
    - paras.fs/(paras.samples*zfill_f2)).';
ppm_scale = (-freq_scale/paras.t_freq)*10^6+ref;

f2_pts = paras.samples;
f1_pts = size(time_sig,2);

freq_scale_f1_raw = linspace(-f1_fs/2,+f1_fs/2-f1_fs/f1_pts,f1_pts).';
freq_scale_f1 = linspace(-f1_fs/2,+f1_fs/2-f1_fs/(f1_pts*zfill_f1),f1_pts*zfill_f1).';

decay_f2 = repmat(exp(-0*t),f1_pts,1).';
decay_f1 = repmat(sin(linspace(0,pi,f1_pts)).^2,f2_pts,1);

decay = decay_f1 .* decay_f2;
%decay = time_sig;
time_sig = time_sig;% .* decay;

spectra = abs(fftshift(fft2(time_sig.',f1_pts*zfill_f1,f2_pts*zfill_f2)));

x=linspace(0,2*pi,100);
y=sin(x);

plot(real(y.*exp(2*pi*2*1i*x)))


spectra_orig = spectra;

% tilt the spectra
%for n = 1:size(spectra,1)
%    spectra(n,:) = real(fft((ifft(spectra(n,:))) .* exp(1i*t_zfill*2*pi*freq_scale_f1(n))));
%for n = 1:size(spectra,1)
%    spectra(n,:) = real(fft((ifft(spectra(n,:))) .* exp(-1i*t_zfill*2*pi*freq_scale_f1(n))));
%end


sub_set_ppm = sum(ppm_scale>max_ppm):sum(ppm_scale>min_ppm);
%sub_set_ppm = 1:2048;


imagesc(ppm_scale(sub_set_ppm),freq_scale_f1,spectra(:,sub_set_ppm))
set(gca,'xDir','reverse')
xlabel('F2 (ppm)');
ylabel('F1 (Hz)');
print('-dpng','-r500','JSTEAM.png');

%imagesc(ppm_scale(sub_set_ppm),freq_scale_f1,spectra(:,sub_set_ppm))


%contour(ppm_scale(sub_set_ppm),freq_scale_f1,spectra(:,sub_set_ppm),30)
%set(gca,'xDir','reverse')
%xlabel('F2 (ppm)');
%ylabel('F1 (Hz)');



%contour(ppm_scale(sub_set_ppm),0:99,spectra(:,sub_set_ppm),20)
%set(gca,'xDir','reverse');



%plot(ppm_scale,-real(fftshift(fft(time_sig(:,25)))))
%xlabel('Frequency (ppm)');
%ylabel('Intensity (au)');
%set(gca, 'xlim', [0.5 4.5]);
%set(gca, 'ylim', plot_params.ylim);
%set(gca,'xDir','reverse');

%contour(spectra(:,1100:end),30)




%contour(abs(fftshift(fft2(time_sig.'))),50)


%plot(-real(fftshift(fft((time_sig(:,3))))))