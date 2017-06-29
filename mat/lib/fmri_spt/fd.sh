#(c) 2012, Ameera X. Patel, University of Cambridge

codedir=$HOME/fmri_spt/code_bin
basedir=`pwd`

usage()
{
cat<<EOF
usage: $0 options

===========================================================================

fMRI SIGNAL PROCESSING TOOLBOX v.1.1
fd.sh 

(c) Ameera Patel, 2012


(as described in Power et al. 2012)

Calculates the framewise displacement

Input: 
    1. The 6 motion parameters (rows=frame#, cols=6 parameters)

Outputs: 
    1. Text file containing vector of values representing FD for each
       frame of data. This script appends _fd to the input file name.
    2. Plot of FD against frame number (OPTIONAL)


OPTIONS:

    -h  Show this message (Flag)
    -i  Motion parameters (text file) [REQUIRED]
        Note, that if you did not use AFNI volreg to output the motion
        parameters, please ensure that the parameters are represented in
        columns. Reformat.sh can be used to automatically format text
        files to the required format.
    -v  verbose (Flag)

Extra options:

    -p  Plot data (Flag)
    -c  RGB colour of output figure [DEFAULT=black]
        Colour options. Please choose from one of the following:
        b = blue, g = green, r = red, c = cyan, m = magenta, y = yellow
        k = black

E.g. bash ~/fmri_spt/fd.sh -i rest_motion.txt -p


============================================================================

EOF
}

input=
colour=
verbose=
plot=

while getopts "hi:c:pv" OPTION
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

if [ -f ${inpstr}_fd.txt ]
then
    echo -e "*** WARNING: OVERWRITING EXISTING FILE ***"
    rm ${inpstr}_fd.txt
fi


# Plotter

if [ "$plot" == 1 ]
then
    python $codedir/FD.py ${input} ${colour}
else
    python $codedir/FD.py ${input}
fi

# Check file output

inpstr=${input%%.*}
if [ ! -f ${inpstr}_fd.txt ]
then    
    echo "Failed to compute DVARS. Please check input file."
    exit 4
fi

echo -e "\nProcess complete. Output file ${inpstr}_fd.txt to working directory\n"