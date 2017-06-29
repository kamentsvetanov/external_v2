% comodulogram() -  calculate phase-amplitude coupling between many
% combinations of low-frequency bands and high-frequency bands
%
% Usage:
%     >> comod = comodulogram(lo, hi, p_range, a_range, dp, da, fs, pac_method);
%
% Inputs:
%     lo          = voltage time series containing the low-frequency-band
%                   oscillation
%     hi          = voltage time series containing the high-frequency-band
%                   oscillation
%     p_range     = range of entire low-frequency band (Hz)
%     a_range     = range of entire high-frequency band (Hz)
%     dp          = frequency window size into which p_range is divided (Hz)
%     da          = frequency window size into which a_range is divided (Hz)
%     fs          = sampling rate (Hz)
%     pac_method  = string defining the phase-amplitude coupling metric to
%                   be used. Must be one of the following:
%                     'mi_tort' - See Tort, 2008
%                     'plv' - See Penny, 2008
%                     'glm' - See Penny, 2008
%                     'mi_canolty' - See Canolty, 2006
%                     'ozkurt' - See Ozkurt & Schnitzler, 2011 
%
% Outputs:
%     comod       = matrix of PAC values for each combination of
%                   low-frequency and high-frequency band. Rows span the
%                   low frequencies and columns span the high frequencies
%
% Example:
%     >> t = 0:.001:10; % Define time array
%     >> lo = sin(t * 2 * pi * 6); % Create low frequency carrier
%     >> hi = sin(t * 2 * pi * 100); % Create modulated oscillation
%     >> hi(angle(hilbert(lo)) > -pi*.5) = 0; % Clip to 1/4 of cycle
%     >> comodulogram(lo, hi, [5,25], [75,175], 10, 50, 1000, 'mi_tort')
%     ans =
%         0.3345    0.3161
%         0.3344    0.3161
%
% See also: comodulogram(), pa_series(), pac_tmi()

% Author: Scott Cole (Voytek lab) 2015

function comod = comodulogram(lo, hi, p_range, a_range, dp, da, fs, pac_method)

    % Convert inputs from MATLAB to Python variables
    lo = py.numpy.array(lo);
    hi = py.numpy.array(hi);
    p_rangepy = py.tuple(p_range);
    a_rangepy = py.tuple(a_range);

    % need to calculate two dimensions and make sure the output makes sense
    comod = py.pacpy.pac.comodulogram(lo, hi, p_rangepy, a_rangepy, dp, da, fs, pac_method);

    % Convert outputs from Python to MATLAB variables
    d1 = ceil((p_range(2)-p_range(1)) / dp);
    d2 = ceil((a_range(2)-a_range(1)) / da);
    comod = double(py.array.array('d',py.numpy.nditer(comod)));
    comod = reshape(comod,[d2,d1])';
end