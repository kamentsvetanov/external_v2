#(c) 2012, Ameera X. Patel, University of Cambridge

codedir=$HOME/fmri_spt/code_bin
basedir=`pwd`

usage()
{
cat<<EOF
usage: $0 options

===========================================================================

fMRI SIGNAL PROCESSING TOOLBOX v.1.1
cloud.sh

(c) Ameera X.Patel, 2012


Computes deltaR (scrubbed correlation matrix - unscrubbed matrix) and 
Euclidean Distance.

Inputs:
    1.  Unscrubbed correlation matrix (as output by correlate.sh).
    2.  Scrubbed correlation matrix (as output by correlate.sh).
    3.  Parcel coordinates. If parcellate.sh was not used, then please 
        ensure that row 1 = x, row 2 = y, row 3 = z coordinates.

Outputs:
    1.  Text file containing scatter point values.
        column 1 = Euclidean distance
        column 2 = deltaR
    2.  Text file containing line fit values. Appends _fit
        to output file name specified.
        column 1 = Euclidean distance values
        column 2 = corresponding deltaR values
    3.  Scatter plot of deltaR vs. euclidean distance [DEFAULT:No plot]
        (OPTIONAL)


OPTIONS:

    -h  Show this message (Flag)
    -i  Unscrubbed correlation matrix (as output by correlate.sh) [REQUIRED]
    -s  Scrubbed correlation matrix (as output by correlate.sh) [REQUIRED]
    -c  Matrix of coordinates as output by parcellate.sh. If parcellate.sh
        used, the file will have the suffix _xyz.txt. [REQUIRED]
        Note, if you did not use parcellate.sh, the matrix should contain 3
        rows (row1 = x, row2 = y,row3 = z) and n columns where n is the 
        number of parcels. The coordinates in column n should represent the 
        time series in column/row n of the correlation matrices. reformat.sh
        can be used to automatically format text files.
    -o  Output file name [DEFAULT='cloud']
    -v  verbose (Flag)

Extra options:

    -p  Plot data (Flag)
    -d  Colour of the scatter points/dots (please see below for colour 
        options) [DEFAULT=blue]
    -l  Colour of best fit line (please see below for colour options)
        [DEFAULT=red]
        A note on colours. Please chose from one of the following options:  
        b = blue, g = green, r = red, c = cyan, m = magenta, y = yellow
        k = black


E.g. bash ~/fmri_spt/cloud.sh -i ppp_ts_corr.txt 
     -s ppp_ts_scrub_corr.txt -c pp_xyz.txt -p 


============================================================================

EOF
}

input=
scrub=
coord=
dots=
line=
output=
plot=
verbose=

while getopts "hi:s:c:d:l:o:pv" OPTION
do
    case $OPTION in
    h)  
        usage
        exit 1
        ;; 
    i)
        input=$OPTARG
        ;;
    s)
        scrub=$OPTARG
        ;;
    c)
        coord=$OPTARG
        ;;
    d)
        dots=$OPTARG
        ;;
    l)
        line=$OPTARG
        ;;
    o)
        output=$OPTARG
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

if [[ -z $input ]] || [[ -z $scrub ]] || [[ -z $coord ]] 
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

if [ "$output" == "" ]
then
    output=cloud
fi

if [ "$dots" == "" ]
then
    dots=b
fi

if [ "$line" == "" ]
then
    line=r
fi


# Check files to prevent script execution with non-existent files.

if [ ! -f $input ];
then
    echo "Cannot locate file $input. Please ensure the $input text file is in this directory"
    exit 2
fi

if [ ! -f $scrub ];
then
    echo "Cannot locate file $scrub. Please ensure the file $scrub is in the working directory"
    exit 3
fi

if [ ! -f $coord ];
then
    echo "Cannot locate coordinates $coord. Please ensure the file $coord is in the working directory"
    exit 4
fi


# Check colour options are legal

if [[ "$line" == 'b' || "$line" == 'g' || "$line" == 'r' || "$line" == 'c' || "$line" == 'm' || "$line" == 'y' || "$line" == 'k' ]] || [[ "$dots" == 'b' || "$dots" == 'g' || "$dots" == 'r' || "$dots" == 'c' || "$dots" == 'm' || "$dots" == 'y' || "$dots" == 'k' ]]
then
    echo ""
else
    echo "Please enter a legitimate colour option. Please see the help file for colour options"
fi

# Overwrite check

if [ -f ${output}.txt ] || [ -f ${output}_fit.txt ]
then
    echo -e "*** WARNING: OVERWRITING EXISTING FILE ***"
    rm ${output}.txt ${output}_fit.txt
fi

# Run

matlab -nodisplay -r "cloud('$input','$scrub','$coord','$output');quit"

# Plotter

if [ "$plot" == 1 ]
then
    python $codedir/scatter.py ${output}.txt ${output}_fit.txt $dots $line
fi

# Check outputs

if [ -f ${output}.txt ]
then
    echo -e "Process complete. Output files ${output}.txt and ${output}_fit.txt to working directory.\n"
fi

stty echo