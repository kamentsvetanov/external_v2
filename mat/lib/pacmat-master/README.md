# pacmat

A MATLAB library for calculating phase-amplitude coupling.

This is a wrapper for a python module that can be found at, https://github.com/voytekresearch/pacpy

MATLAB version 2014b or later is required.

## Install : MATLAB

## Install : Python

[Anaconda](https://store.continuum.io/cshop/anaconda/) or another version of python with scientific packages should be installed.

Then, pacpy must be installed (not yet uploaded to pypi).  To install:

1. `git clone https://github.com/voytekresearch/pacpy` into the directory of your choice.
2. At the command line, cd into that choice directory
3. and type `pip install .`

Users must also install the statsmodels package (pip install statsmodels). This dependency will be removed in a later version.

## Usage

An example of calculating PAC from two simulated voltage signals using the phase-locking value (PLV) method:

		>> t = 0:.001:10; % Define time array
		>> lo = sin(t * 2 * pi * 6); % Create low frequency carrier
		>> hi = sin(t * 2 * pi * 100); % Create modulated oscillation
		>> hi(angle(hilbert(lo)) > -pi*.5) = 0; % Clip to 1/4 of cycle
		>> pac_plv(lo, hi, [4,8], [80,150], 1000) % Calculate PAC
		ans =
			0.9981