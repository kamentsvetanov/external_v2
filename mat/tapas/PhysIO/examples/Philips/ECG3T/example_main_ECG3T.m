% example_main_ECG3T
% ==================
%
% Script that executes ECG 3T Philips logfile. Just press play (F5)
% Download the logfile from 
%       http://www.translationalneuromodeling.org/software/tapas-data/
%
% Note:
%       
% - For documentation of any of the defined substructures here, please
%   see also tapas_physio_new.m or the Manual_PhysIO-file.
%
%
% Author: Lars Kasper
% Created: 2013-02-18
% Copyright (C) 2015 TNU, Institute for Biomedical Engineering,
%           University of Zurich and ETH Zurich.
%
% This file is part of the PhysIO toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.
%
% $Id: example_main_ECG3T.m 652 2015-01-24 10:15:28Z kasperla $
%
%% 0. Put code directory into path; for some options, SPM should also be in the path

pathRETROICORcode = fullfile(fileparts(mfilename('fullpath')), ...
    '../../../code');

addpath(genpath(pathRETROICORcode));

physio      = tapas_physio_new();         % create structure, numbering according to *PhysIO_PhysNoiseBackground.pptx
log_files   = physio.log_files;     % 1a) Read logfiles
sqpar       = physio.sqpar;         % 1b) Sequence timing
thresh      = physio.thresh;        % 2) Preprocess phys & align scan-timing
model       = physio.model;         % 3)/4) Model physiological time series
verbose     = physio.verbose;       % Auxiliary: Output


%% 1. Define Input Files

log_files.vendor            = 'Philips';
log_files.cardiac           = 'SCANPHYSLOG.log';
log_files.respiration       = 'SCANPHYSLOG.log';



%% 2. Define Nominal Sequence Parameter (Scan Timing)

sqpar.Nslices           = 37;
sqpar.NslicesPerBeat    = 37; % typically equivalent to Nslices; exception: heartbeat-triggered sequence
sqpar.TR                = 2.50;
sqpar.Ndummies          = 3;
sqpar.Nscans            = 495;
sqpar.onset_slice       = 19;
sqpar.Nprep             = []; % set to >=0 to count scans and dummy
% volumes from beginning of run, i.e. logfile,
% includes counting of preparation gradients
sqpar.time_slice_to_slice  = sqpar.TR / sqpar.Nslices;



%% 3. Order of RETROICOR-expansions for cardiac, respiratory and
%% interaction terms. Option to orthogonalise regressors

model.type = 'RETROICOR';
model.order = struct('c',3,'r',4,'cr',1, 'orthogonalise', 'none');
model.input_other_multiple_regressors = 'rp_fMRI.txt'; % either .txt-file or .mat-file (saves variable R)
model.output_multiple_regressors = 'multiple_regressors.txt';

%% 4. Define Gradient Thresholds to Infer Gradient Timing (Philips only)
%
% method to determine slice onset times
% 'nominal' - to derive slice acquisition timing from sqpar directly
% 'gradient' or 'gradient_log' - derive from logged gradient time courses
%                                in SCANPHYSLOG-files (Philips only)
thresh.scan_timing.method = 'gradient_log'; %'gradient_log'; 'nominal'
thresh.scan_timing.grad_direction = 'y';
thresh.scan_timing.zero         = 0.4;
thresh.scan_timing.slice        = 0.45;
thresh.scan_timing.vol          = [];   % leave [], if unused; set value >=.slice,
% if volume start gradients are higher than slice gradients
thresh.scan_timing.vol_spacing  = [];   % leave [], if unused; set to e.g. 50e-3 (seconds),
% if there is a time gap between last slice of a volume
% and first slice of the next



%% 5. Define which Cardiac Data Shall be Used

thresh.cardiac.modality = 'ECG';
thresh.cardiac.initial_cpulse_select.method = 'load_from_logfile';
thresh.cardiac.posthoc_cpulse_select.method = 'off';



%% 6. Output Figures to be generated

verbose.level           = 2; % 0 = none; 1 = main plots (default);  2 = debugging plots, for setting up new study; 3 = all plots
verbose.fig_output_file = 'PhysIO_output_level2.fig'; % Physio.tiff, .ps, .fig possible


%% 7. Run the main script with defined parameters

physio.log_files    = log_files;
physio.sqpar        = sqpar;
physio.model        = model;
physio.thresh       = thresh;
physio.verbose      = verbose;

[physio_out, R, ons_secs] = tapas_physio_main_create_regressors(physio);
