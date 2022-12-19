% TFCE Toolbox
% Version  223  (version 1.0) 2021-08-12
% __________________________________________________________________________
% Copyright (C) 2020 Christian Gaser christian.gaser@uni-jena.de
%
% $Id: Contents_info.txt 203 2020-06-23 08:56:50Z gaser $
% ==========================================================================
% Description
% ==========================================================================
% This toolbox is a an extension to SPM12 (Wellcome Department of Cognitive 
% Neurology) to provide non-parametric statistics based on threshold-free
% cluster enhancement (TFCE). It is developed by Christian Gaser (University of 
% Jena, Department of Psychiatry) and is available to the scientific 
% community under the terms of the GNU General Public License.
%
% General files
%   spm_TFCE.m             - GUI
%   TFCE.man               - notes on TFCE toolbox
%   CHANGES.txt            - changes in revisions
%
% TFCE functions
%   tfce_estimate.m        - TFCE core function
%   tfce_results_ui.m      - call results
%   tfce_getSPM.m          - get TFCE results
%   tfce_list.m            - list result table
%   tfce_update.m          - get TFCE update
%   tfce_progress.m        - display progress and remaining time
%   tbx_cfg_tfce.m         - toolbox function
%   snpm_P_FDR.m           - FDR correction from SnPMs
%
%
% Mex- and c-functions
%   tfceMex_pthread.c      - TFCE-transformation 
%