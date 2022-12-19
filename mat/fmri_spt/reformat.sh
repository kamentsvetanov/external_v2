#(c) 2012, Ameera X. Patel, University of Cambridge

codedir=$HOME/fmri_spt/code_bin
basedir=`pwd`

usage()
{
cat<<EOF
usage: $0 options

===========================================================================

fMRI SIGNAL PROCESSING TOOLBOX v.1.1
reformat.sh 

(c) Ameera X. Patel, 2012


This program reformats text files into a format that is compatible with
the usage of python in this toolbox. Please note: if you have used
parcellate.sh to compute regional time series, your files will not
require any reformatting.


OPTIONS:

    -h  Show this message (Flag)
    -i  Input text file (any format) [REQUIRED]
    -n  Number of frames of data in your dataset [REQUIRED]
    -v  verbose (Flag)


E.g. bash ~/fmri_spt/reformat.sh -i time_series.txt


============================================================================

EOF
}

input=
verbose=
num=

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
    v)
        verbose=1
        ;;
    n)
        num=$OPTARG
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
    exit 2
fi


# Verbose option

if [ "$verbose" == 1 ]
then
    set -x verbose
fi

#  File check

if [ ! -f ${inpstr} ]
then
    echo "File could not be found."
    exit 3
fi

# Overwrite check

inpstr=${input%%.*}

if [ -f ${inpstr}.txt ]
then
    echo -e "\n*** WARNING: OVERWRITING EXISTING FILE ***"
fi

matlab -nodisplay -r  "reformat('$input','$num');quit"
