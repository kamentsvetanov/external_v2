****************************************************
ICC toolbox for SPM5
 
Centre for Neuroimaging Sciences
Institute of Psychiatry
King's College London
 
 
Alejandro Caceres 2008
***************************************************

icc_toolbox 

Test-retest studies are essential to determine the reliability of functional 
magnetic resonance imaging (fMRI). Together with studies of statistical power, 
they constitute the basis for the design of large longitudinal experiments.

This toolbox calculates a range of reliability measures: The intra-class 
correlation coefficient (ICC), coefficient of variation (CV) and within-subjects
and error variances. 

The ICC conveniently assesses either the absolute or consistent agreement of subject 
activations from session to session(Shrout & Fleiss 1979. Psychol Bull 86 (2), 420?8). 
It can also be used to assess the level of heterogeneity of the subject sample. The 
methods are explained here**link to document download**.


FEATURES:

-Produces all three types of ICC maps and for any amount of sessions. Mean squares 
maps are produced and ICC(3,1) is converted to a fisher's Z map: ICC_z.img.
The ICC maps can be examined for the whole brain volume, the activation network and defined 
clusters. 

-Extracts summary statistics within ROIs masks (abtained by MarsBar) and computes 
ICCs (with p values) and Coefficient of Variation.

-Computes intravoxel ICCs.
 
-Can be used for other modalities.

****************************************************
REQUIREMENTS:
 
The routines have been written for SPM5**link to http://www.fil.ion.ucl.ac.uk/spm/** (on MATLAB 7.4.0) 
and use the statistics toolbox 6 for MATLAB
  
Set up:
 
1. Copy the icc_toolbox directory in your disk space and when you open MATLAB, make sure 
that both this directory and the SPM5 library are on MATLAB path. -i.e. in MATLAB, go to 
SPM5 and icc_toolbox directories and when you are there simply write >>path(pwd,path)
 
2. For the cluster reliability you need marsbar-devel-0.41**link to http://marsbar.sourceforge.net/**, 
download it and put it in the path of Matlab too.
 
3. The routines calculate the test-retest reliability of contrast images of functional 
data for a particular task (other modalities can also be used). So prior to the analysis 
you need to get these images for each subject. The toolbox assumes that 
you have fitted the first level statistical model. 

4. Open the toolbox by typing >>gui_icc


******************************************************


STEP-BY-STEP:

Here we give a step-by-step analysis that can be used with the sample data provided.
A quick description of the utilities, and explore results options is given at the end of the 
document.

 
Analysis:
 
The contrast files should be organized as follows:
 
 
suppose that you have 10 subjects and two sessions, then select the contrast images in the
order
 
sub1_con_0001.img
sub2_con_0001.img
.
.
.
sub20_con0001.img
 
the first 10 images must represent the first session of the 10 subjects and the images 
from 11 to 20 are the second session of the subjects in the same order (sub1 corresponds 
to sub11, sub2 to sub12, etc). Subsequent sessions can be included in the same manner.
 
Under utilities, you can use the copy files option to copy all the files you need in this
way.  However, it requires that the contrast images, you want to use, always have the same
contrast number across all subjects. 
 
a. select copy files. 
b. select root directory, that is the directory where you will create a subdirectory where 
you are going to store all the contrast images.
c. select subject directories. Those are the directories where the first level analyses 
for each subject are. The script will go to each directory and automatically select the 
contrast you indicate. 
d. write the name of the directory where the images are to be stored (default name: results).
e. finally complete the name of the contrast you want to pick up from each subject analysis
directory. 
example: type an extra 1, at the end of con_000 to pick up the contrast con_0001.
 
 
**************************************************
There is a directory with sample data (nback-task: memory retrieval contrasts) in the 
sample director that can be used as an example.
 
Intra-subject reliability in the Brain and Network
 
1. Mask the images first. Select mask image. 
1a. Select images. 
1b. Explicit mask: n -writes a mask where every voxel has data for every image.
 
The process produces m_****.img images, which are the images to use in the reliability 
calculation.
 
2. Select one sample t. This opens the SPM5 gui to define second level analysis. Follow 
the gui and select basic stats, one sample t-test and the masked images of the first 
session. Using SPM5 suite check your results and on the glass brain results page check 
the t-threshold associated to the voxel p-threshold you use to define the significant 
activated regions. The toolbox estimates the model including the group contrast. 
 
3. Now you can compute the ICC maps. Press the button: compute ICC maps. 
3.a Select all the masked images
3.b Select number of sessions (if you are using the sample data set then select 2). Wait 
few seconds and then your ICC maps will be ready. The process produces a map for each of 
the three types of ICCs, the ICC_Z which is the fisher's Z transform for the ICC of the 
third kind (ICC(3,1)=ICC_2A_con)  and the different maps for the sums of squares. 
 
4. Explore results.
4.a Select distribution and medians
4.b Select the ICC map you are interested in (for consistency agreement: ICC_2A_con)
4.c Select the spmT map associated with the first session group analysis.
4.d Input the t-threshold for the map. (This is the t-threshold obtain in step 2, 
select 4.5 if you are using the sample data)
4.e Input the threshold for deactivated regions (usually the negative of the previous one)
4.f Select ROI masks? Replace y for n.   
 
As a result you will have a series of plots. 
a. the joint probability distribution of ICC and t-values across the brain
b. the relative voxel frequency of ICC values across the brain and network, and an 
additional plot that includes the deactivated network.
c. the median values of each distribution with corresponding confidence intervals.  The 
brain median  should be lower than the network median and we've found the deactivated 
network to fall bellow the whole brain median.
   
**************************************   
Intra-subject reliability for clusters
 
1. extract activated clusters for the SPM.mat (seccion 2 above) using  >>marsbar 
 
1.a under: ROI definition, select Get SPM cluster(s), follow SPM results (get a cluster 
size big enough to end up with only significant clusters).
 
1.b in the left lower panel of SPM there is a menu called: write ROI(s) (top left next to
Design). Under this menu select: write all clusters; chose the current directory; root
name for clusters; This writes all the clusters in the directory in the format .mat. 
 
1.c On the MarsBar window under ROI definition select Export...; export to image; select
first cluster; in space for RIO image select base space for ROIs; then choose current
directory and image filename. This writes the cluster as a .nii image. Repeat this step for
all the clusters.
 
1.d On the gui_icc window select nii2img, under utilities. This converts all the nii 
cluster masks into .img with the dimension format of a reference image. Select all the 
nii images exported in the previous section, then select any of the contrast images used 
in the computation of ICC maps.
 
2. Select ?distributions and medians? under explore results. Follow previous section 4. In step 4.f  
this time choose the cluster masks from the outcome of the previous step . 
 
In addition to previous results you should get the relative voxel frequency of ICC values 
across the ROIs and a comparison between medias across ROIs that you can extract on the 
command line.
 
*************************************
Utilities:
 
1-copy files: copies the contrast images for all subjects into a given directory.
Refer to set up analysis at the top of this document.
 
2-Mask images: mask the images specified (contrast images) by an expicit mask or by a mask
that represents the voxels for which data is present in all images. The mask is stored in 
Mask01.img. New images are written with the prefix m_***.img, where voxels outside the mask 
are replaced by NaNs. If an explicit mask is specified the routine asks weather the specified 
images to mask have the same dimensions of the mask asking:
 
dim(mask)=dim(img): yes|no ,  if the answer is no (or don?t know) it will convert the mask to 
the dimensions of the specified images. For this you'll need to provide a reference image 
(any contrast image).
 
3-one sample t-test: it is a shortcut for 2nd SPM5 level analysis. We typically run the test 
for the first session under the question: "how likely is that voxels found with high group t in 
the first session will have a consistent signal across sessions, not at a group level but for 
each individual subject"
 
4-nii2img: converts a nii image to an .img with the dimensions specified by the reference image. 
Use this utility to convert to the proper format and dimensions mask images extracted with 
marsbar.  
 
5-Fisher's z map: converts ICC maps into fisher's z.
 
6-ROI summary stats: Retrieves the mean, median, peak value of a subject contrast image (or any
selected image) within an ROI defined by a mask. It checks that the ROI mask has the same 
dimension than the selected images (check number 2 above). It writes the results in txt files 
that can be used into reliability calculations in the following utility. Each txt file is the
list of summary stats of each image (subject) within the specified ROI. 
 
7-ICC and CV for summary stats: The list of summary stats saved in txt files above (that contain
the summary stats of each subject within a particular ROI) can be used to determine the three
types of ICC (and p values) together with the coefficient of variance. The list has to follow 
the order indicated in the set up analysis section at the top of this document.
 
 
Explore results
besides the analysis described in the step-by-step section there are the following additional 
options:
 
1-Threshold variations:
 
This option allows to assess the variation of the median ICC in the network when this last one 
is defined by increasing threshold values. It plots the median ICC of the network to its 
group t-threshold
 
2-intravoxel reliability
 
Given an ROI, ICCs and the coefficient of variation can be calculated for each subject using 
the set of voxels within the region as the measurement sample under repeated measures. This 
option produces a plot for each subject of the voxel values for session 1 against session 2. It
computes the ICC for each subject and runs a bootstrap of the values in order to infer a 
population estimate. The option only supports 2 sessions. 
 
 
3-ICC and smoothing
 
This can be use to analysis the effect of smoothing to a FWHM in the ICC computations. For this 
analysis is recommended to obtain the contrast images of each subject without any smoothing of 
the time series. Using this option, the contrast images are then smoothed for different 
smoothing kernels and the corresponding median ICCs for the network and brain are computed. As 
a result a plot of median ICCs against smoothing kernel is produced. Note that the smoothing 
kernel is specified not in mm but in the factor that the original voxel size will be 
multiplied in each of its dimensions.   
 
To run this analysis:
(you can use the sample data in provided) 
a-select network threshold. This option is dependent on your data and the value should not 
be used as default. Find a suitable threshold from your one sample t analysis. 
 
b-select working directory select unmasked (original) contrast images. 
 
c-provide the kernel factors in: times voxel size
 
d-number of sessions: (2)
 
e-select explicit mask: NO
 
wait it until it displays the SPM5 window to define your one sample group t test for the first
session. Follow the single stats and one sample t test options. Now, select the images that 
have been mask smoothed and masked again. Those begin with the prefix m_sm_***.img.  Follow the 
default options. 


