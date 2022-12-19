#(c) 2012, Ameera X. Patel, University of Cambridge

pkgdir=$HOME/fmri_spt
basedir=`pwd`

usage()
{
cat<<EOF
usage: $0 options

===========================================================================

fMRI SIGNAL PROCESSING TOOLBOX v.1.1
randscrub.sh

(c) Ameera X. Patel 2012


Randomly removes time frames from time series data

Inputs:
    1.  Parcellated time series (as output by parcellate.sh)
    2.  Number of frames to remove.

Output:
    1.  Randomly scrubbed time series. Output appends _randscrub to 
        input time series file name.


OPTIONS:

    -h  Show this message (Flag)
    -i  Matrix of time series as output by 'parcellate.sh', as a text 
        file [REQUIRED]
        Note, if you did not use parcellate.sh, the time series should be
        represented in columns.
    -n  Number of frames to remove [REQUIRED]
    -v  Verbose (Flag)



E.g. bash ~/fmri_spt/randscrub.sh -i ppp_ts.txt -n 40


============================================================================

EOF
}

input=
num=
verbose=

while getopts "hi:n:v" OPTION
do
    case $OPTION in
    h)  
        usage
        exit 1
        ;; 
    i)
        input=$OPTARG
        ;;
    n)
        num=$OPTARG
        ;;
    v)
        verbose=1
        ;;
    ?)
        usage
        exit 1
        ;;
    esac
done

if [[ -z $input ]] || [[ -z $num ]]
then
    usage
    exit 1
fi

# Verbose option

if [ "$verbose" == 1 ]
then
    set -x verbose
fi

# Check files to prevent script execution with non-existent files.

if [ ! -f $input ];
then
    echo "Cannot locate file $input. Please ensure the $input text file is in the current working directory."
    exit 2
fi

# Overwrite check

inpstr=${input%%.*}

if [ -f ${inpstr}_randscrub.txt ]
then
    echo -e "\n*** WARNING: OVERWRITING EXISTING FILE ***"
    rm ${inpstr}_randscrub.txt
fi

# Run

matlab -nodisplay -r "randscrub('$input','$num');quit"

if [ ! -f ${inpstr}_randscrub.txt ]
then
    echo -e "\nFailed to write file.\n"
    exit 5
fi

echo -e "\nProcess complete.\n"
