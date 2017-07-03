WFU TOOLBOXES BETA RELEASE
---------------------------------------------------------------------
The beta package is distributed with this directory structure:
	wfu_toolboxes/
		wfu_startup.m
		wfu_bpm/
		wfu_compatibility/
		wfu_insertion_tool/
		wfu_pickatlas/
		wfu_utilities/
	wfu_bpm_data/
		bpm_img/
		bpm_results/
		bpm_simulated_data/

---------------------------------------------------------------------
REQUIREMENTS:
        SPM2 or SPM5
        MATLAB version 6.5 or higher
---------------------------------------------------------------------

*********************************************************************
DOWNLOAD, EXTRACT, SELECT TOOLBOXES
*********************************************************************
For UNIX, download the compressed unix tar file, wfu_bpm_beta.tar.gz,
and extract with:
	gunzip wfu_bpm_beta.tar.gz
	tar xvf wfu_bpm_beta.tar

For PC/WINDOWS, download and unzip the contents of the WINDOWS ZIP
file, wfu_bpm_beta.zip.

Edit wfu_startup.m inside the wfu_toolboxes directory to select the
WFU toolbox options for your site.  Set each of the following
parameters to 0 (for no) or 1 (for yes):
	add_bpm
	add_insertion_tool
	add_utilities
	add_compatibility
	add_pickatlas

Add compatibility only if reconciliation with SPM-99 input is needed.

*********************************************************************
RUNNING THE WFU TOOLBOXES
*********************************************************************
(1) Once the SPM2 or SPM5 path is set in MATLAB and spm_defaults
has been called, add the path of the wfu_toolboxes directory.
For example, if located here:
	c:\software\wfu_toolboxes
then issue this command:
	addpath('c:\software\wfu_toolboxes');

(2) Add the paths for all the selected WFU toolboxes with:
	wfu_startup;

(3) Run the toolbox of choice.  To execute BPM:
	wfu_bpm;
