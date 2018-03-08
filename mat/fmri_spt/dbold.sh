#(c) 2012, Ameera X. Patel, University of Cambridge

codedir=$HOME/fmri_spt/code_bin
basedir=`pwd`

usage()
{
cat<<EOF
usage: $0 options

===========================================================================

fMRI SIGNAL PROCESSING TOOLBOX v.1.1
dbold.sh 

(c) Ameera X. Patel, 2012


(as described in Power et al. 2012)

Calculates delta%BOLD fluctuations on time series after parcellation.

Input:  
    1.  Text file containing matrix of parcellated time series (as output 
        from parcellate.sh). Please note that if parcellate.sh was not used 
        to compute regional time series, then the time series must be 
        represented in columns. reformat.sh can be used to automatically
        format files.

Output: 
    1.  Text file containing matrix of time series representing d%BOLD. This 
        script appends _dbold to the input file name.


A note on algorithms. If you wish to replicate the Power et al., 2012 method
of calculating delta%BOLD, you MUST have mode or median 1000 normalised
during pre-processing. If you have used speedypp.py to pre-process your data, 
then median normalisation has been implemented. 

If you have not mode/median 1000 normalised, then please use the alternate 
algorithm by specifying the -a flag. This computes delta%BOLD in a different 
way. Please also note that if you use the alterate algorithm, the input data 
MUST still contain the time series means. The alternate algorithm will not 
work if the time series have been band-passed or de-meaned prior to using 
this program.


OPTIONS :

    -h  Show this message 
    -i  Text file containing matrix of parcellated time series
        Note, if parcellate.sh was not used to create these time series,
        please ensure that the time series are represented in columns.
        [REQUIRED].
    -a  Please use this flag if you HAVE NOT mode/median normalised your
        data during pre-processing. Note, if you used speedypp.py, then you 
        do not need to use this flag.
    -v  Verbose


E.g. bash ~/fmri_spt/dbold.sh -i ppp_ts.txt



============================================================================

EOF
}

input=
verbose=
aa=

while getopts "hi:av" OPTION
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


# Check options to prevent script execution with non-existent files.

if [ ! -f $input ];
then
    echo "Cannot locate file $input. Please ensure that $input is in the current working directory, and is entered correctly."
    exit 2
fi

# Overwrite check

inpstr=${input%%.*}

if [ -f ${inpstr}_dbold.txt ]
then
    echo -e "\n*** WARNING: OVERWRITING EXISTING FILE ***"
    rm ${inpstr}_dbold.txt
fi

# Check algorithm and Run

if [ "$aa" == 1 ]
then
    python $codedir_dBOLD_AA.py ${input}
else
    python $codedir/dBOLD.py ${input}
fi

# Check file output

if [ ! -f ${inpstr}_dbold.txt ]
then
    echo "File not written to disk. Please check inputs and try again."
else
    echo -e "\nProcess complete. Output file ${input%%.*}_dbold.txt to working directory\n"
fi
