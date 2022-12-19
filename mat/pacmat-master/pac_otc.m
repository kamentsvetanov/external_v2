% pac_otc() -  calculate phase-amplitude coupling (PAC) using the
%     oscillation-triggered coupling (OTC) method (see Dvorak, 2014)
%
% Usage:
%     >> pac = pac_otc(x, f_hi, f_step, fs, w, event_prc, t_modsig, t_buffer);
%
% Inputs:
%     x           = voltage time series
%     f_hi        = range of entire high-frequency band (Hz)
%     f_step      = frequency window size into which f_hi is divided (Hz)
%     fs          = sampling rate (Hz)
%     w           = length of the filter in terms of the number of cycles
%                   of the frequency at the center of the bandpass filter
%     event_prc   = percentile threshold of the power signal of an
%                   oscillation for a high-frequency event to be declared
%                   (between 0 and 100)
%     t_modsig    = time range of the modulation signal
%     t_buffer    = minimum time (seconds) between consecutive
%                   high-frequency events
%
% Outputs:
%     pac         = phase-amplitude coupling value
%
% Example:
%     >> t = 0:.001:10; % Define time array
%     >> lo = sin(t * 2 * pi * 6); % Create low frequency carrier
%     >> hi = sin(t * 2 * pi * 100); % Create modulated oscillation
%     >> hi(angle(hilbert(lo)) > -pi*.5) = 0; % Clip to 1/4 of cycle
%     >> pac_otc(lo + hi, [80,150], 4, 1000, 7, 95, [-1,1], .01)
%     ans =
%         1.9679
%
% See also: comodulogram(), pa_series(), pa_dist()

% Author: Scott Cole (Voytek lab) 2015

function pac = pac_otc(x, f_hi, f_step, fs, w, event_prc, t_modsig, t_buffer)

    % Convert inputs
    xpy = py.numpy.array(x);
    f_hipy = py.tuple(f_hi);
    t_modsigpy = py.tuple(t_modsig);

    % Call python
    otcout = py.pacpy.pac.otc(xpy, f_hipy, f_step, fs, w, event_prc, t_modsigpy, t_buffer);

    % Separate outputs
    pac = otcout{1};

    %tf = otcout{2}; User can calculate this in matlab.
    % Run into error in conversion: Python Error: can't convert complex to float

    % a_events = otcout{3};
    % Unclear how to convert this to a cell array in MATLAB

    % mod_sig = otcout{4};
    % mod_sig = double(py.array.array('d',py.numpy.nditer(mod_sig)));
    % mod_sig = reshape(mod_sig,[Tmod,Nfreqs])';
end