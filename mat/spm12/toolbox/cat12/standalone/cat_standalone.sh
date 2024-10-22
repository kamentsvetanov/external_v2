#! /bin/bash
# ______________________________________________________________________
#
# Christian Gaser, Robert Dahnke
# Structural Brain Mapping Group (http://www.neuro.uni-jena.de)
# Departments of Neurology and Psychiatry
# Jena University Hospital
# ______________________________________________________________________
# $Id: cat_standalone.sh 1841 2021-06-01 10:03:38Z gaser $

########################################################
# global parameters
########################################################
version='cat_standalone.sh $Id: cat_standalone.sh 1841 2021-06-01 10:03:38Z gaser $'

cwd=$(dirname "$0")

if [ ! -n "$SPMROOT" ]; then
  SPMROOT=$(dirname "${cwd}")
fi

# get cat12 dir
ARCH=`uname`
if [ "$ARCH" == "Darwin" ]; then
  cat12_dir="${SPMROOT}/spm12.app/Contents/MacOS/spm12/toolbox/cat12" 
else
  cat12_dir="your_folder/spm12/toolbox/cat12" 
fi

########################################################
# run main
########################################################

main ()
{
  parse_args ${1+"$@"}
  check_files
  run_cat

  exit 0
}

########################################################
# check arguments and files
########################################################

parse_args ()
{
  local optname optarg
  count=0
  paras=

  if [ $# -lt 1 ]; then
    help
    exit 1
  fi
    
  while [ $# -gt 0 ]; do
    optname="`echo $1 | sed 's,=.*,,'`"
    optarg="`echo $2 | sed 's,^[^=]*=,,'`"
    paras="$paras $optname $optarg"
    case "$1" in
        --batch* | -b*)
            exit_if_empty "$optname" "$optarg"
            BATCHFILE=$optarg
            shift
            ;;
        --mcr* | -m*)
            exit_if_empty "$optname" "$optarg"
            MCRROOT=$optarg
            shift
            ;;
        --spm* | -s*)
            exit_if_empty "$optname" "$optarg"
            SPMROOT=$optarg
            shift
            ;;
        --arg1* | -a1*)
            exit_if_empty "$optname" "$optarg"
            ARG1=$optarg
            shift
            ;;
        --arg2* | -a2*)
            exit_if_empty "$optname" "$optarg"
            ARG2=$optarg
            shift
            ;;
        --add* | -a*)
            exit_if_empty "$optname" "$optarg"
            add_to_defaults="$optarg"
            shift
            ;;
        -h | --help | -v | --version | -V)
            help
            exit 1
            ;;
        -*)
            echo "`basename $0`: ERROR: Unrecognized option \"$1\"" >&2
            ;;
        *)
            ARRAY[$count]=$1
            ((count++))
            ;;
    esac
    shift
  done
}

########################################################
# check arguments
########################################################

exit_if_empty ()
{
  local desc val

  desc="$1"
  shift
  val="$*"

  if [ ! -n "$val" ]; then
    echo 'ERROR: No argument given with \"$desc\" command line argument!' >&2
    exit 1
  fi
}

########################################################
# check files
########################################################

check_files ()
{
  
  # check for MCR parameter
  if [ ! -n "$MCRROOT" ]; then
    echo "No MCR folder defined."
    help
    exit 1  
  fi
  
  # check for MCR folder
  if [ ! -d "$MCRROOT" ]; then
    echo "No MCR folder found."
    help
    exit 1  
  fi

  # check for SPM parameter
  if [ ! -n "$SPMROOT" ]; then
    echo "No SPM folder defined."
    help
    exit 1  
  fi
  
  # check for SPM folder
  if [ ! -f "$SPMROOT/run_spm12.sh" ]; then
    echo "File $SPMROOT/run_spm12.sh not found found."
    help
    exit 1  
  fi

  # check for batch file
  if [ ! -n "$BATCHFILE" ]; then
    echo "No batch file defined."
    help
    exit 1  
  fi

  # check for files
  i=0
  while [ "$i" -lt "$count" ]
  do
    if [ ! -f "${ARRAY[$i]}" ]; then
      if [ ! -L "${ARRAY[$i]}" ]; then
        echo ERROR: File ${ARRAY[$i]} not found
        help
        exit 1
      fi
    fi
    ((i++))
  done

}

########################################################
# run CAT
########################################################

run_cat ()
{
  
  # if no files are given expect that file name is defined
  # in batch file and execute that file
  if [ "$count" -eq "0" ]; then
    eval "\"${SPMROOT}/run_spm12.sh\"" $MCRROOT "batch" $BATCHFILE
    exit 0
  fi
  
  # create temporary batch file
  TMP=/tmp/cat_$$.m

  # copy everything except rows with UNDEFINED to temp file 
  grep -v "<UNDEFINED>" $BATCHFILE > $TMP
  
  # extract parameter name of data structure (1st occurance of "<UNDEFINED>")
  data=`grep -m 1 "<UNDEFINED>" $BATCHFILE | cut -f1 -d'='| sed -e 's,%,,'`

  # extract parameter name of optional argument(s) (additional occurances of "<UNDEFINED>")
  if [ -n "$ARG1" ]; then # ARG1 defined?
    param1=`grep -m 2 "<UNDEFINED>" $BATCHFILE | tail -n 1 | cut -f1 -d'=' | sed -e 's,%,,'`
    # extract parameter name of optional argument (3rd occurance of "<UNDEFINED>")
    if [ -n "$ARG2" ]; then # ARG2 defined?
      param2=`grep -m 3 "<UNDEFINED>" $BATCHFILE | tail -n 1 | cut -f1 -d'=' | sed -e 's,%,,'`
    fi
  fi
  
  # surface data need an additional curly bracket
  if grep -q -e "\.datalong" $BATCHFILE ; then
    echo "$data = {{" >> $TMP
  else
    echo "$data = {" >> $TMP
  fi
  
  i=0
  ARG_LIST=""
  while [ "$i" -lt "$count" ]; do

    # check whether absolute or relative names were given
    if [ ! -f ${ARRAY[$i]} ];  then
      if [ -f ${PWD}/${ARRAY[$i]} ]; then
        FILE=${PWD}/${ARRAY[$i]}
      fi
    else
      FILE=${ARRAY[$i]}
    fi

    # add file list
    echo "'${FILE}'" >> $TMP
              
    ((i++))
  done

  # surface data need an additional curly bracket
  if grep -q -e "\.datalong" $BATCHFILE ; then
    echo "     }};" >> $TMP
  else
    echo "     };" >> $TMP
  fi
  
  if [ -n "$ARG1" ]; then # ARG1 defined?
    echo "$param1 = $ARG1 ;" >> $TMP
    if [ -n "$ARG2" ]; then # ARG2 defined?
      echo "$param2 = $ARG2 ;" >> $TMP
    fi
  fi
  
  # add optional lines to defaults file
  if [ -n "$add_to_defaults" ]; then
    echo "${add_to_defaults}" >> ${TMP}
  fi

  eval "\"${SPMROOT}/run_spm12.sh\"" $MCRROOT "batch" $TMP
  rm $TMP
  exit 0
}


########################################################
# help
########################################################

help ()
{

  # do not use a single dot
  if [ "$SPMROOT" == "." ]; then
    SPMROOT="SPMROOT"
  fi

cat <<__EOM__

USAGE:
   cat_standalone.sh filename(s) [-s spm_standalone_folder] [-m mcr_folder] [-b batch_file] 
                                 [-a1 additional_argument1] [-a2 additional_argument2]
                                 [-a add_to_defaults]
   
   -s <DIR>    | --spm <DIR>     SPM12 folder of standalone version (can be also defined by SPMROOT)
   -m <DIR>    | --mcr <DIR>     Matlab Compiler Runtime (MCR) folder (can be also defined by MCRROOT)
   -b <FILE>   | --batch <FILE>  batch file to execute
   -a1 <STRING>| --arg1 <STRING> 1st additional argument (otherwise use defaults)
   -a2 <STRING>| --arg2 <STRING> 2nd additional argument (otherwise use defaults)
   -a <FILE>   | --add  <FILE>   add option to default file

   The first occurance of the parameter "<UNDEFINED>" in the batch file will be replaced by the
   list of input files. You can use the existing batch files in this folder or create your own batch 
   file with the SPM12 batch editor and leave the data field undefined. Please note that for creating
   your own batch file CAT12 has to be called in expert mode because the CAT12 standalone installation 
   will only run in expert mode to allow more options.
   See cat_standalone_segment.m for an example. 
   
   You can also define one or two optional arguments to change other parameters that are indicated by 
   "<UNDEFINED>" in the batch file. Please take care of the order of the "<UNDEFINED>" fields in the 
   batch file! If no additional arguments are defined the default values are used.
   
   If you use a computer cluster it is recommended to use the batch files to only process one data set 
   and use a job or queue tool to call the (single) jobs on the cluster.
   
PURPOSE:
   Command line call of (CAT12) batch files for SPM12 standalone installation

EXAMPLES
   -----------------------------------------------------------------------------------------------
   Segmentation
     -a1 TPM
     -a2 Shooting template
   -----------------------------------------------------------------------------------------------
   cat_standalone.sh -s $SPMROOT -m /Applications/MATLAB/MATLAB_Runtime/v93 \ 
       -b ${cwd}/cat_standalone_segment.m sTRIO0001.nii
   Preprocess (segment) the single file sTRIO0001.nii using the default CAT12 preprocessing batch. 
   SPM12 standalone version is located in $SPMROOT and Matlab Compiler Runtime in
   /Applications/MATLAB/MATLAB_Runtime/v93.

   cat_standalone.sh -s $SPMROOT -m /Applications/MATLAB/MATLAB_Runtime/v93 \ 
       -b ${cwd}/cat_standalone_segment.m sTRIO000*.nii.gz \ 
       -a1 "${cat12_dir}/templates_MNI152NLin2009cAsym/TPM_Age11.5.nii" \ 
       -a2 "${cat12_dir}/templates_MNI152NLin2009cAsym/Template_0_GS1mm.nii"
   Unzip and preprocess (segment) the files sTRIO0001.nii.gz using the default CAT12 preprocessing 
   batch, but use the children TPM provided with CAT12 and a 1mm Shooting template (not provided 
   with CAT12). Please not that zipped file can only be handled with this standalone batch.

   cat_standalone.sh -s $SPMROOT -m /Applications/MATLAB/MATLAB_Runtime/v93 \ 
       -b ${cwd}/cat_standalone_segment.m sTRIO0001.nii \ 
       -a "cat.extopts.WMHC = 3;"
   Preprocess (segment) the single file sTRIO0001.nii using the default CAT12 preprocessing batch, 
   but handle WMHs as separate class

   -----------------------------------------------------------------------------------------------
   Longitudinal Segmentation
     -a1 longitudinal model (1 - aging/developmental; 2 - plasticity/learning)
     -a2 TPM
   -----------------------------------------------------------------------------------------------
   cat_standalone.sh -s $SPMROOT -m /Applications/MATLAB/MATLAB_Runtime/v93 \ 
       -b ${cwd}/cat_standalone_segment_long.m sTRIO000*.nii \ 
       -a1 "2"
   Preprocess (segment) the files sTRIO000*.nii with the longitudinal pipeline optimized for 
   detecting aging/developmental effects. In order to choose the longitudinal model optimized for 
   detecting small changes due to plasticity/learning change the a1 parameter to "1".

   cat_standalone.sh -s $SPMROOT -m /Applications/MATLAB/MATLAB_Runtime/v93 \ 
       -b ${cwd}/cat_standalone_segment_long.m sTRIO000*.nii \ 
       -a1 "1" -a2 "${cat12_dir}/templates_MNI152NLin2009cAsym/TPM_Age11.5.nii"
   Preprocess (segment) the files sTRIO000*.nii with the longitudinal pipeline optimized for 
   detecting plasticity/learning effects and use the children TPM provided with CAT12.

   -----------------------------------------------------------------------------------------------
   Segmentation (Simple Mode)
   -----------------------------------------------------------------------------------------------
   cat_standalone.sh -s $SPMROOT -m /Applications/MATLAB/MATLAB_Runtime/v93 \ 
       -b ${cwd}/cat_standalone_simple.m sTRIO0001.nii
   Process the single file sTRIO0001.nii using the simple processing batch. 

   -----------------------------------------------------------------------------------------------
   Resample & Smooth Surfaces
     -a1 smoothing filter size surface values
     -a2 use 32k mesh from HCP (or 164k mesh from Freesurfer)
   -----------------------------------------------------------------------------------------------
   cat_standalone.sh -s $SPMROOT -m /Applications/MATLAB/MATLAB_Runtime/v93 \ 
       -b ${cwd}/cat_standalone_resample.m lh.thickness.sTRIO0001 \ 
       -a1 "12" -a2 "1" 
   Resample and smooth the single thickness file lh.thickness.sTRIO0001 with 12mm and save the 
   resampled mesh as 32k mesh (HCP conform mesh). Only the left surface file has to be defined.
   The right hemisphere is processed automatically.

   -----------------------------------------------------------------------------------------------
   Smoothing
     -a1 smoothing filter size
     -a2 prepending string for smoothed file (e.g. 's6')
   -----------------------------------------------------------------------------------------------
   cat_standalone.sh -s $SPMROOT -m /Applications/MATLAB/MATLAB_Runtime/v93 \ 
       -b ${cwd}/cat_standalone_smooth.m sTRIO*nii \ 
       -a1 "[6 6 6]" -a2 "'s6'"
   Smooth the volume files sTRIO*nii with 6mm and prepend the string "s6" to the smoothed files.

   -----------------------------------------------------------------------------------------------
   Dicom Import
     -a1 directory structure
     -a2 output directory
   -----------------------------------------------------------------------------------------------
   cat_standalone.sh -s $SPMROOT -m /Applications/MATLAB/MATLAB_Runtime/v93 \ 
       -b ${cwd}/cat_standalone_dicom2nii.m *.dcm \ 
       -a1 "'patid_date'" -a2 "{'converted'}"
   Import DICOM files *.dcm and save converted nifti files in directory "converted" with structure 
   ./<PatientID>/<StudyDate-StudyTime>/<ProtocollName>
   Other options for directory structure are:
     'flat'       No directory hierarchy
     'series'     ./<ProtocollName>
     'patid_date' ./<PatientID>/<StudyDate-StudyTime>/<ProtocollName>
     'patid'      ./<PatientID>/<ProtocollName>
     'date_time'  ./<StudyDate-StudyTime>/<ProtocollName>

   -----------------------------------------------------------------------------------------------
   De-Facing
   -----------------------------------------------------------------------------------------------
   cat_standalone.sh -s $SPMROOT -m /Applications/MATLAB/MATLAB_Runtime/v93 \ 
       -b ${cwd}/cat_standalone_deface.m sTRIO*.nii
   Apply de-facing to sTRIO*.nii and save the files prefixed by "anon_".

   -----------------------------------------------------------------------------------------------
   Estimate and Save Quality Measures for Volumes or Surfaces
     -a1 csv output filename
     -a2 enable global scaling with TIV (only for volumes meaningful)
   -----------------------------------------------------------------------------------------------
   cat_standalone.sh -s $SPMROOT -m /Applications/MATLAB/MATLAB_Runtime/v93 \ 
       -b ${cwd}/cat_standalone_get_quality.m mwp1sTRIO*nii \ 
       -a1 "'Quality_measures.csv'" -a2 "1"
   Estimate mean z-scores using global scaling with TIV for the files mwp1sTRIO*nii and save quality 
   measures in Quality_measures.csv for external analysis. Processing of surface meshes is also
   supported.
   
   -----------------------------------------------------------------------------------------------
   Estimate mean/volume inside ROI
     -a1 output-file string
   -----------------------------------------------------------------------------------------------
   cat_standalone.sh -s $SPMROOT -m /Applications/MATLAB/MATLAB_Runtime/v93 \ 
       -b ${cwd}/cat_standalone_get_ROI_values.m catROI_*.xml \ 
       -a1 "'ROI'" 
    Save mean volume values in mL (e.g. GM volume) or the mean surface values (e.g. thickness) for 
    all data catROI_*.xml in a csv-file. The csv-file is named "ROI_" followed by the atlas name
    and the name of the measure (e.g. Vgm).

   -----------------------------------------------------------------------------------------------
   TFCE Statistical Estimation
     -a1 contrast number
     -a2 number of permutations
   -----------------------------------------------------------------------------------------------
   cat_standalone.sh -s $SPMROOT -m /Applications/MATLAB/MATLAB_Runtime/v93 \ 
       -b ${cwd}/cat_standalone_tfce.m SPM.mat \ 
       -a1 "2" -a2 "20000"
   Call estimation of TFCE statistics for the given SPM.mat file for contrast number 2 with 20000 
   permutations.

   -----------------------------------------------------------------------------------------------
   Parallelization
   -----------------------------------------------------------------------------------------------
   cat_parallelize.sh -p 8 -l /tmp \ 
       -c "cat_standalone.sh  -s $SPMROOT -m /Applications/MATLAB/MATLAB_Runtime/v93 -b ${cwd}/cat_standalone_segment.m" sTRIO*.nii
   Parallelize CAT12 preprocessing by splitting all sTRIO*.nii files into 8 jobs 
   (processes) and save log file in /tmp folder. 

   The parameters SPMROOT and MCRROOT have to be defined (exported) to skip the use of the flags -s -m.

INPUT:
   nifti files or surface data

OUTPUT:
   processed images and optionally surfaces according to settings in cat_standalone_*.m

USED FUNCTIONS:
   cat_parallelize.sh
   SPM12 standalone version (compiled)
   CAT12 toolbox (compiled within SPM12 if installed)
   MATLAB Compiler Runtime R2017b (Version 9.3)

This script was written by Christian Gaser (christian.gaser@uni-jena.de).
This is ${version}.

__EOM__
}

########################################################
# call main program
########################################################

main ${1+"$@"}
