FITv2.0c Updates (Dec 05, 2012):

1. Added an option to set min and max limits for threshold in display GUI of joint ICA and parallel ICA. The following files are modified:
	a. ica_fuse\ica_fuse_display\ica_fuse_applyDispParameters.m
	b. ica_fuse\ica_fuse_display\ica_fuse_create_composite.m
	c. ica_fuse\ica_fuse_display\ica_fuse_create_movie_erp_fmri.m
	d. ica_fuse\ica_fuse_display\ica_fuse_display.m
	e. ica_fuse\ica_fuse_display\ica_fuse_overlayImages.m
	f. ica_fuse\ica_fuse_display\ica_fuse_scaleImage.m
	g. ica_fuse\ica_fuse_display\ica_fuse_parallelICA\ica_fuse_parallelICA_displayGUI.m

FITv2.0c Updates (June 26, 2012):

1. Default correlation threshold in parallel ICA is set based on p < 0.05.

FITv2.0c Updates (June 25, 2012):

1. Correlation threshold to constrain the components is updated based on the sample size. The following files are added or modified:	
	a. ica_fuse\ica_fuse_parallelICA\ica_fuse_paraICAOptions.m
	b. ica_fuse\ica_fuse_parallelICA\ica_fuse_setup_parallelICA.m
	c. ica_fuse\ica_fuse_spm8_files\ica_fuse_spm_invBcdf.m
	d. ica_fuse\ica_fuse_spm8_files\ica_fuse_spm_invTcdf.m

FITv2.0c Updates (June 20, 2012):

1. Extra column corresponding to correlations is removed in the dominant snps text file. Fixed file ica_fuse\ica_fuse_parallelICA\ica_fuse_parallelICA_displayGUI.m.


FITv2.0c Updates (June 13, 2012):

1. Fixed error message "Undefined function or variable featureData" when doing leave one out evaluation. The following files are modified:
	a. ica_fuse\ica_fuse_parallelICA\ica_fuse_calculate_parallelICA.m
	b. ica_fuse\ica_fuse_parallelICA\ica_fuse_leave_one_out.m
	c. ica_fuse\ica_fuse_parallelICA\ica_fuse_run_parallelICA.m


