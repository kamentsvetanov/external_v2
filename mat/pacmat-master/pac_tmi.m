% pac_tmi() -  calculate phase-amplitude coupling (PAC) using the
%     modulation index (MI) method (see Tort, 2008)
%
% Usage:
%     >> pac = pac_tmi(lo, hi, f_lo, f_hi, fs, Nbins);
%
% Inputs:
%     lo          = voltage time series containing the low-frequency-band
%                   oscillation
%     hi          = voltage time series containing the high-frequency-band
%                   oscillation
%     f_lo        = cutoff frequencies of low-frequency band (Hz)
%     f_hi        = cutoff frequencies of high-frequency band (Hz)
%     fs          = sampling rate (Hz)
%     Nbins       = Number of bins that the low-frequency period is split
%                   into
%
% Outputs:
%     pac         = phase-amplitude coupling value
%
% Example:
%     >> t = 0:.001:10; % Define time array
%     >> lo = sin(t * 2 * pi * 6); % Create low frequency carrier
%     >> hi = sin(t * 2 * pi * 100); % Create modulated oscillation
%     >> hi(angle(hilbert(lo)) > -pi*.5) = 0; % Clip to 1/4 of cycle
%     >> pac_tmi(lo, hi, [4,8], [80,150], 1000, 20) % Calculate PAC
%     ans =
%         0.3408
%
% See also: comodulogram(), pa_series(), pa_dist()

% Author: Scott Cole (Voytek lab) 2015

function pac = pac_tmi(lo, hi, f_lo, f_hi, fs, Nbins)

    % Convert inputs
    lo = py.numpy.array(lo);
    hi = py.numpy.array(hi);
    f_lo = py.tuple(f_lo);
    f_hi = py.tuple(f_hi);

    % Call python
    pac = py.pacpy.pac.mi_tort(lo, hi, f_lo, f_hi, fs, Nbins);
end