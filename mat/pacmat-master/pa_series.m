% pa_series() -  calculate the phase time series of a low frequency
%     oscillation and the amplitude time series of a high frequency
%     oscillation
%
% Usage:
%     >> [pha, amp] = pa_series(lo, hi, f_lo, f_hi, fs);
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
%     pha         = phase time series
%     amp         = amplitude time series
%
% Example:
%     >> t = 0:.001:10; % Define time array
%     >> lo = sin(t * 2 * pi * 6); % Create low frequency carrier
%     >> hi = sin(t * 2 * pi * 100); % Create modulated oscillation
%     >> hi(angle(hilbert(lo)) > -pi*.5) = 0; % Clip to 1/4 of cycle
%     >> [pha, amp] = pa_series(lo, hi, [4,8], [80,150], 1000);
%     >> amp(1)
%     ans =
%         0.1801
%
% See also: comodulogram(), pa_dist()

% Author: Scott Cole (Voytek lab) 2015

function [pha, amp] = pa_series(lo, hi, f_lo, f_hi, fs)

    % Convert inputs
    lo = py.numpy.array(lo);
    hi = py.numpy.array(hi);
    f_lo = py.tuple(f_lo);
    f_hi = py.tuple(f_hi);

    % Call python
    phaamp = py.pacpy.pac.pa_series(lo, hi, f_lo, f_hi, fs);

    % Convert outputs to MATLAB variables
    pha = double(py.array.array('d',py.numpy.nditer(phaamp{1})));
    amp = double(py.array.array('d',py.numpy.nditer(phaamp{2})));
end