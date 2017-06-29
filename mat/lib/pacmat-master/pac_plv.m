% pac_plv() -  calculate phase-amplitude coupling (PAC) using the
%     phase-locking value (PLV) method (see Penny, 2008)
%
% Usage:
%     >> pac = pac_plv(lo, hi, f_lo, f_hi, fs);
%
% Inputs:
%     lo          = voltage time series containing the low-frequency-band
%                   oscillation
%     hi          = voltage time series containing the high-frequency-band
%                   oscillation
%     f_lo        = cutoff frequencies of low-frequency band (Hz)
%     f_hi        = cutoff frequencies of high-frequency band (Hz)
%     fs          = sampling rate (Hz)
%
% Outputs:
%     pac         = phase-amplitude coupling value
%
% Example:
%     >> t = 0:.001:10; % Define time array
%     >> lo = sin(t * 2 * pi * 6); % Create low frequency carrier
%     >> hi = sin(t * 2 * pi * 100); % Create modulated oscillation
%     >> hi(angle(hilbert(lo)) > -pi*.5) = 0; % Clip to 1/4 of cycle
%     >> pac_plv(lo, hi, [4,8], [80,150], 1000) % Calculate PAC
%     ans =
%         0.9981
%
% See also: comodulogram(), pa_series(), pa_dist()

% Author: Scott Cole (Voytek lab) 2015

function pac = pac_plv(lo, hi, f_lo, f_hi, fs)

    % Convert inputs
    lo = py.numpy.array(lo);
    hi = py.numpy.array(hi);
    f_lo = py.tuple(f_lo);
    f_hi = py.tuple(f_hi);

    % Call python
    pac = py.pacpy.pac.plv(lo, hi, f_lo, f_hi, fs);
end