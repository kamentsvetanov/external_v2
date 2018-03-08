% pa_dist() -  calculate the distribution of amplitude over an oscillatory
%     cycle
%
% Usage:
%     >> [bins, dist] = pa_dist(pha, amp, Nbins);
%
% Inputs:
%     pha         = phase time series
%     amp         = amplitude time series
%     Nbins       = Number of bins that the low-frequency period is split
%                   into
%
% Outputs:
%     bins        = phase time series
%     dist        = amplitude time series
%
% Example:
%     >> t = 0:.001:10; % Define time array
%     >> lo = sin(t * 2 * pi * 6); % Create low frequency carrier
%     >> hi = sin(t * 2 * pi * 100); % Create modulated oscillation
%     >> hi(angle(hilbert(lo)) > -pi*.5) = 0; % Clip to 1/4 of cycle
%     >> [pha, amp] = pa_series(lo, hi, [4,8], [80,150], 1000);
%     >> [binds, dist] = pa_dist(pha, amp, 20);
%     >> dist(1)
%     ans =
%         0.7829
%
% See also: comodulogram(), pa_series(), pac_tmi()

% Author: Scott Cole (Voytek lab) 2015

function [bins, dist] = pa_dist(pha, amp, Nbins)

    % Convert inputs
    pha = py.numpy.array(pha);
    amp = py.numpy.array(amp);

    % Call python
    binsdist = py.pacpy.pac.pa_dist(pha, amp, Nbins);

    % Convert outputs
    bins = double(py.array.array('d',py.numpy.nditer(binsdist{1})));
    dist = double(py.array.array('d',py.numpy.nditer(binsdist{2})));
end