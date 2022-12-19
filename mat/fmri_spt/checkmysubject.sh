#(c) 2012, Ameera X. Patel, University of Cambridge

pkgdir=$HOME/fmri_spt
basedir=`pwd`

usage()
{
cat<<EOF
usage: $0 options

===========================================================================

fMRI SIGNAL PROCESSING TOOLBOX v.1.1
checkmysubject.sh

(c) Ameera X. Patel 2012


Tells you which subjects to include and which to exclude.

Inputs:
    1.  Parcellated time series (as output by parcellate.sh)
    2.  FD (as output by fd.sh)
    3.  DVARS (as output by dvars.sh)
    4.  Dataset rejection criteria (upper bound of scrubbed frames allowed). 
        All data with less than this fraction of frames scrubbed
        will be accepted. [DEFAULT=0.45].

Output:
    1.  Commandline output telling you to keep or reject.


OPTIONS:

    -h  Show this message (Flag)
    -i  Matrix of time series as output by 'parcellate.sh', as a text 
        file [REQUIRED]
        Note, if you did not use parcellate.sh, the time series should be
        represented in columns. Reformat.sh can be used to automatically
        format your matrix.
    -f  Framewise displacement (as output by fd.sh) [REQUIRED]
        Note, if you did not use fd.sh, this should be a column vector.
    -d  DVARS (as output by dvars.sh) [REQUIRED]
        Note, if you did not use dvars.sh, this should be a column vector.
    -r  Rejection fraction - please enter a number between 0 and 1. This is
        the upper bound of bad frames allowed to keep dataset. [DEFAULT=0.45].

Extra Options:

    -p  Use the DVARS threshold described in Power et al. (2012).
        Please note that this threshold is only relevant for pre-processing
        methods described in that paper. Omit this flag to use an analagous
        threshold more relevant to this set of pre-processing methods. See
        release notes for more information [DEFAULT=Off] (Flag).
    -v  Verbose (Flag) 



E.g. bash ~/fmri_spt/checkmysubject.sh -i ppp_ts.txt -f rest_motion_fd.txt
     -d rest_pp_dvars.txt -r 0.45


============================================================================

EOF
}

input=
fd=
dvars=
reject=
verbose=

while getopts "hi:f:d:r:pv" OPTION
do
    case $OPTION in
    h)  
        usage
        exit 1
        ;; 
    i)
        input=$OPTARG
        ;;
    f)
        fd=$OPTARG
        ;;
    d)
        dvars=$OPTARG
        ;;
    r)
        reject=$OPTARG
        ;;
    v)
        verbose=1
        ;;
    p)
        power=1
        ;;
    ?)
        usage
        exit 1
        ;;
    esac
done

if [[ -z $input ]] || [[ -z $fd ]] || [[ -z $dvars ]]
then
    usage
    exit 1
fi

# Set default

if [ "$reject" == "" ]
then
    reject=0.5
fi

# Verbose option

if [ "$verbose" == 1 ]
then
    set -x verbose
fi


# Check files to prevent script execution with non-existent files.

if [ ! -f $input ];
then
    echo "Cannot locate file $input. Please ensure $input is in the current working directory."
    exit 2
fi

if [ ! -f $fd ];
then
    echo "Cannot locate file $fd. Please ensure the file $fd is in the current working directory."
    exit 3
fi

if [ ! -f $dvars ];
then
    echo "Cannot locate file $dvars. Please ensure the file $dvars is in the current working directory"
    exit 4
fi

# Overwrite check

inpstr=${input%%.*}

# Set thresholds and run

if [ "$power" == 1 ]
then
    matlab -nodisplay -r "checkmysubject('$input','$dvars','$fd','$reject','1');quit"
else
    matlab -nodisplay -r "checkmysubject('$input','$dvars','$fd','$reject','0');quit"
fi

echo
stty echo
