#(c) 2012, Ameera X. Patel, University of Cambridge

codedir=$HOME/fmri_spt/code_bin
basedir=`pwd`

usage()
{
cat<<EOF
usage: $0 options

===========================================================================

fMRI SIGNAL PROCESSING TOOLBOX v.1.1
loess.sh 

(c) Ameera Patel, 2012


Plots FD against d%BOLDx10 and computes the loess curve of the data

Inputs:  
    1. Framewise displacement (as output by fd.sh)
    2. detla%BOLDx10 on parcellated data (as output by dbold.sh)
    3. Output prefix for loess curve data

Outputs: 
    1. Text file containing vector of loess curve values.
           column 1 = sorted FD values
           column 2 = corresponding loess curve values
    2. Plot of FD vs. delta%BOLDx10 with a fitted loess curve overlayed
       (OPTIONAL)


OPTIONS:

    -h  Show this message (Flag)
    -f  Framewise disaplacement column vector (as output by fd.sh)
        [REQUIRED]
    -d  d%BOLDx10, the derivative of percent signal change after 
        parcellation (as output by d%bold.sh) [REQUIRED]
    -o  Output file name for loess curve text file [DEFAULT='loess']
    -v  Verbose (Flag)

Extra options:

    -p  Plot data (Flag)
    -s  Scatter point colour (please see below for colour options)
        for output figure [DEFAULT=blue]
    -l  Loess curve colour (please see below for colour options) for
        output figure [DEFAULT=red]
        Colour options. Please choose from one of the following:
        b = blue, g = green, r = red, c = cyan, m = magenta, y = yellow
        k = black

E.g. bash ~/fmri_spt/loess.sh -f rest_motion_fd.txt 
     -d ppp_ts_dbold.txt -p 


============================================================================

EOF
}

fd=
dbold=
output=
scatter=
line=
plot=
verbose=

while getopts "hf:d:o:s:l:pv" OPTION
do
    case $OPTION in
    h)  
        usage
        exit 1
        ;; 
    f)
        fd=$OPTARG
        ;;
    d)
        dbold=$OPTARG
        ;;
    o)
        output=$OPTARG
        ;;
    s)
        scatter=$OPTARG
        ;;
    l)
        line=$OPTARG
        ;;
    p)
        plot=1
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

if [[ -z $fd ]] || [[ -z $dbold ]]
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

if [ "$scatter" == "" ]
then
    scatter=b
fi

if [ "$line" == "" ]
then
    line=r
fi

if [ "$output" == "" ]
then
    output=loess
fi

# Check options to prevent script execution with non-existent files.

if [ ! -f $fd ];
then
    echo "Cannot locate file $fd. Please ensure that $fd is in the current working directory"
    exit 2
fi

if [ ! -f $dbold ];
then
    echo "Cannot locate file $dbold. Please ensure that $dbold is in the current working directory."
    exit 3
fi

if [[ "$scatter" == 'b' || "$scatter" == 'g' || "$scatter" == 'r' || "$scatter" == 'c' || "$scatter" == 'm' || "$scatter" == 'y' || "$scatter" == 'k' ]] || [[ "$line" == 'b' || "$line" == 'g' || "$line" == 'r' || "$line" == 'c' || "$line" == 'm' || "$line" == 'y' || "$line" == 'k' ]]
then
    echo ""
else
    echo "Please enter a legitimate colour option. Please see the help file for options"
    exit 4
fi

# Overwrite check

if [ -f ${output}.txt ]
then
    echo -e "*** WARNING: OVERWRITING EXISTING FILE ***"
    rm ${output}.txt
fi

# Run

matlab -nodisplay -r "loess('$fd','$dbold','$output');quit"


# Plotter

if [ "$plot" == 1 ]
then
    python $codedir/loess.py ${fd} ${dbold} ${output}.txt ${scatter} ${line}
fi

# Check outputs

if [ -f ${output}.txt ]
then
    echo -e "Process complete. Output file ${output}.txt to working directory.\n"
else
    echo -e "\nFailed to compute loess curve. Please check inputs.\n"
fi
