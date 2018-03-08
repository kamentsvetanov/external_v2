#(c) 2012, Ameera X. Patel, University of Cambridge

codedir=$HOME/fmri_spt/code_bin
basedir=`pwd`

usage()
{
cat<<EOF
usage: $0 options

===========================================================================

fMRI SIGNAL PROCESSING TOOLBOX v.1.1
correlate.sh

(c) Ameera X.Patel, 2012


Computes Pearson correlation coefficients for input time series

Input:
    1.  Matrix of time series. Note, if parcellate.sh was not used to 
        produce the time series, then please ensure the time series are 
        represented in columns. Reformat.sh can be used to automatically
        format files.
    2.  Histogram representing distribution of correlation values.

Output:
    1.  Text file containing matrix of correlation coefficients. The matrix
        is symmetrical.


OPTIONS:

    -h  Show this message (Flag)
    -i  Time series. Please ensure that the time series are represented in
        columns if parcellate.sh was not used to produce the time series.
        [REQUIRED].
    -p  Plot histogram of correlation values (Flag)
    -v  verbose (Flag)

E.g. bash ~/fmri_spt/correlate.sh -i ppp_ts.txt -p


============================================================================

EOF
}

input=
verbose=

while getopts "hi:pv" OPTION
do
    case $OPTION in
    h)  
        usage
        exit 1
        ;; 
    i)
        input=$OPTARG
        ;;
    v)
        verbose=1
        ;;
    p)
        plot=1
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


# Check files to prevent script execution with non-existent files.

if [ ! -f $input ];
then
    echo "Cannot locate file $input. Please ensure the $input text file is in this directory"
    exit 2
fi

# Overwrite check

inpstr=${input%%.*}

if [ -f ${inpstr}_corr.txt ]
then
    echo -e "\n*** WARNING: OVERWRITING EXISTING FILE ***"
    rm ${inpstr}_corr.txt
fi

# Run

matlab -nodisplay -r "correlate('$input');quit"

if [ "$plot" == 1 ]
then
    python $codedir/histogram.py ${inpstr}_corr.txt
fi

# Check outputs

if [ -f ${inpstr}_corr.txt ]
then
    echo -e "Process complete. Output correlation matrix ${inpstr}_corr.txt to working directory.\n"
fi

stty echo
