#(c) 2012, Ameera X. Patel, University of Cambridge

codedir=$HOME/fmri_spt/code_bin
basedir=`pwd`

usage()
{
cat<<EOF
usage: $0 options

===========================================================================

fMRI SIGNAL PROCESSING TOOLBOX v.1.1
dvars.sh 

(c) Ameera X. Patel, 2012


Calculates the RMS of the derivative of voxel intensities, on an input
NIFTI file.

Input:
    1. NIfTI file of pre-processed functional MRI data.

Outputs: 
    1. Text file containing vector of values representing DVARS for each 
       frame of data. This script appends _dvars to the input file name. 
       The y-axis scale is %BOLDx10.
    2. Plot of DVARS against frame number (OPTIONAL)


A note on algorithms. If you wish to replicate the Power et al., 2012 DVARS
method, then you must mode or median normalise to 1000 during pre-processing.
If you have used speedypp.py to pre-process your data, then median
normalisation has been implemented. If you have not mode/median 1000
normalised, then please use the alternate algorithm by specifying the -a
flag. This computes DVARS in a different way. Please also note that if you
use the alterate algorithm, the input data MUST still contain the voxel 
means. The alternate algorithm will not work if the voxel time series have been
band-passed or de-meaned prior to using this program.


OPTIONS:

    -h  Show this message (Flag)
    -i  Pre-processed fMRI data (NIfTI file) [REQUIRED]
    -v  verbose (Flag)
    -a  Please use this flag if you HAVE NOT mode/median normalised your
        data during pre-processing. Note, if you used speedypp.py, then you 
        do not need to use this flag.

Extra Options:

    -p  Plot data (Flag)
    -c  RGB colour of output figure [DEFAULT=black]
        Colour options. Please choose from one of the following:
        b = blue, g = green, r = red, c = cyan, m = magenta, y = yellow
        k = black

E.g. bash ~/fmri_spt/dvars.sh -i rest_pp.nii.gz -p


============================================================================

EOF
}

input=
colour=
verbose=
plot=
aa=

while getopts "hi:c:pav" OPTION
do
    case $OPTION in
    h)  
        usage
        exit 1
        ;; 
    i)
        input=$OPTARG
        ;;
    c)
        colour=$OPTARG
        ;;
    v)
        verbose=1
        ;;
    p)
        plot=1
        ;;
    a)
        aa=1
        ;;
    ?)
        usage
        exit 1
        ;;
    esac
done

if [[ -z $input ]]
then
    usage
    exit 1
fi


# Verbose option

if [ "$verbose" == 1 ]
then
    set -x verbose
fi

# Set defaults

if [ "$colour" == "" ]
then
    colour=k
fi

# Check options to prevent script execution with non-existent files.

if [ ! -f $input ];
then
    echo "Cannot locate file $input. Please ensure that $input is in the current working directory, and is entered correctly."
    exit 2
fi

if [[ "$colour" == 'b' || "$colour" == 'g' || "$colour" == 'r' || "$colour" == 'c' || "$colour" == 'm' || "$colour" == 'y' || "$colour" == 'k' ]]
then
    echo ""
else
    echo "Please enter a legitimate colour option. Please see the help file for options"
    exit 3
fi

# Overwrite check

inpstr=${input%%.*}

if [ -f ${inpstr}_dvars.txt ]
then
    echo -e "*** WARNING: OVERWRITING EXISTING FILE ***"
    rm ${inpstr}_dvars.txt
fi


# Choose algorithm and Run

if [  "$aa" == 1 ]
then
    if [ $plot == 1 ]
    then
        python $codedir/DVARS_AA.py ${input} ${colour}
    else
        python $codedir/DVARS_AA.py ${input}
    fi
else
    if [ "$plot" == 1 ]
    then
        python $codedir/DVARS.py ${input} ${colour}
    else
        python $codedir/DVARS.py ${input}
    fi
fi

# Check file output

inpstr=${input%%.*}
if [ ! -f ${inpstr}_dvars.txt ]
then    
    echo "Failed to compute DVARS. Please check input file."
    exit 4
fi

echo -e "\nProcess complete. Output file ${inpstr}_dvars.txt to working directory\n"
