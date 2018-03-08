ART_REPAIR v4

This version is an update for ArtRepair5 (for SPM5) and ArtRepair2 (for SPM2).
It is named ArtRepair in the SPM toolbox window.
   June 10, 2009.  - pkm

COMPATIBILITIES
   Tested for SPM5, and backward compatible with SPM2.
   Compatible with 3D nifti files, or AnalyzeFormat.
   NOT compatible with 4D nifti files.
   NOT tested for SPM8b or SPM8, although some parts may work.
   
CHANGES from v3.1 (May 2009)
   New art_motionregress, an alternative to using motion regressors
   New art_despike,  removes spikes and slow-varying background voxelwise
   New art_rms,  calculates image of rms variations of set of images
   New art_plottimeseries,  plots timeseries for a voxel
   
CHANGES from v2.2 (2007) are:
   Same toolbox serves both SPM5 and SPM2.

   Assumes that each session is realigned and repaired separately.
      This approach is similar to SPM standard procedures,
      and clinical subjects commonly move between sessions.
      Previous version v2.2 assumed all sessions were realigned together.

   New art_groupcheck to help a user validate group results
   New art_groupoutlier program to identify outlier subjects
   New art_groupsummary program to find GQ scores for a group result
   New art_percentscale program to find percent scaling.
      Documentation is on the ArtRepair website.
      
   Updated art_global
       User must now realign and repair each session separately.
    
   Simplified art_redo. User must now repair and validate results manually.
       Previously, the repair and compare functions were embedded,
       which made the code brittle.
    
   Improved reliability of scaling in art_movie; now mean image is 1000.
    
   Fixed bug in art_summary in order to scale contrasts correctly
    
   Removed art_batch programs, and art_deweightSPM program
   
BUG FIXES from v3
   Add use deweight as default in art_redo
   Improve functionality across SPM versions with strcmp command.

     
Detailed changes
----------------

art_motionregress
   Estimates and removes interpolation artifacts before design estimation.
   Fractional amount removed is greater at edges, less in center of brain.
   Writes new images with prefix "m".
   Use on realigned, resliced images. 
   Must use before normalization, else large images use huge memory.

art_despike
   Clips spikes more extreme than a user-specified threshold, default=4%.
   Option for two different high-pass filters, or an HRF matched filter
   Despike and filter can be applied separately, or in combination.
   Writes new images with prefix "d".
   Must use before normalization, else large images use huge memory.

art_groupcheck
   Allows user to review group results for contrasts and ResMS by voxel.
   Allows user to review all contrasts for all subjects using a movie.
   Allows user to find outlier subjects.
   Scales contrasts into percent signal change for viewing.

art_groupsummary
   Calculates Global Quality scores for a group result
   
art_groupoutlier
   Compares Global Quality scores across subjects to find outlier subjects.
   Suggests good subgroups to use.
   
art_percentscale
   Calculates scale factors to convert results into percent signal change,
   as described in the document FMRIPercentSignalChange.
   
art_global
   User should realign and repair each session separately.
   Global intensity threshold varies more as motion threshold is changed.
   Global intensity threshold is linked to adaptive motion threshold.
   
art_activationmap3
   The colormap used in art_groupcheck to display the contrast images.
   
art_redo
   User must repair scans first, each session repaired separately.
   Program will apply deweighting, and estimate results for repaired files.
   Program will write a new SPM.mat file to a new results folder.
   User must compare results, before and after, with Global Quality.
   (The previously used embedded functionality in v2.2 was brittle.)
   
art_movie
   Fixed bug that caused movie frame to shift (from Volkmar Glauche).
   Image intensities are now scaled so that mean of image is 1000,
   which means that scale value of 160 is exactly 16% signal change.
   Previously scaling was based on peak intensity, so output values
   were not as reliable.

art_summary
   Scales Global Quality for contrasts by the sum of the positive terms of 
   the contrast vector c. Previously it was the RMS norm of c. 
 
   
NOTES for v2.2  (Aug. 2007)
spm_ArtRepair2 or spm_ArtRepair5
   Menu opens in SPM Interactive Window
   with same menu format as many other Toolbox programs..
   This change makes menu compatible with Matlab 6.5.1.
   (Old style menu is available as:  >> old_ArtRepair5)

art_global
   Also marks scan BEFORE large movement for repair.
      Before it only marked the scan after.

   Allows RepairType = 2 to not add margin in automatic mode
   (planning for compatibility with motion regressors).

   Add "Clip" button to mark all movements larger than 3 mm.

   Fixed logic bug for case when user applies his own mask.
 
art_redo
   Changed logic to redo an i.i.d. design as an i.i.d design.
   Previously, i.i.d. became AR(0.2) from an interaction bug with SPM.

   Automatically scales for peak of design regressor, and 
   norm of the contrast vector.


