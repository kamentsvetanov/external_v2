#(c) 2012, Ameera X. Patel, University of Cambridge

tempdir=$HOME/fmri_spt/templates/parcel_temps
basedir=`pwd`

usage()
{
cat<<EOF
usage: $0 options

===========================================================================

fMRI SIGNAL PROCESSING TOOLBOX v.1.1
locate.sh

(c) Ameera X.Patel, 2012


Outputs brain location of input x,z,y coordinates.

Input:
    1.  x,y,z coordinates
    2.  coordinate system (MNI, MNI_ANAT or TLRC) [DEFAULT=TLRC]. If you
        have used parcellate.sh then you need not specify this option.

Output:
    1.  Brain regions within 5 mm radius of input coordinates (can be 
        saved to text file if the -o flag is specified).


OPTIONS:

    -h  Show this message (Flag)
    -x  x coordinate [REQUIRED]
    -y  y coordinate [REQUIRED]
    -z  z coordinate [REQUIRED]
    -s  coordinate system of input coorinates (MNI, MNI_ANAT, TLRC).
        [DEFAULT=TLRC].
    -o  Save screen output to file. File will be named x_y_z.txt, where
        x,y,z are input coordinates (Flag)
    -v  verbose (Flag)

E.g. bash ~/fmri_spt/locate.sh -x 12 -y 12 -z 12 -o 


============================================================================

EOF
}

xcoord=
ycoord=
zcoord=
space=
verbose=
output=

while getopts "hx:y:z:s:ov" OPTION
do
    case $OPTION in
    h)  
        usage
        exit 1
        ;; 
    x)
        xcoord=$OPTARG
        ;;
    y)
        ycoord=$OPTARG
        ;;
    z)
        zcoord=$OPTARG
        ;;
    v)
        verbose=1
        ;;
    o)
        output=1
        ;;
    s)
        space=$OPTARG
        ;;
    ?)
        usage
        exit 1
        ;;
    esac
done

if [[ -z $xcoord ]] || [[ -z $ycoord ]] || [[ -z $zcoord ]]
then
    usage
    exit 1
fi

# Verbose option

if [ "$verbose" == 1 ]
then
    set -x verbose
fi

# Set default space if option empty

if [ "$space" == "" ]
then
    space=TLRC
fi

# Check for correct input template space

if [[ "$space" == "TLRC" || "$space" == "MNI_ANAT" || "$space" == "MNI" ]]
then
    echo ""
else
    echo "Invalid template space option. Please enter either TLRC, MNI or MNI_ANAT. If the field is left empty, TLRC will be used."
fi

# Overwrite check

if [ -f ${save}.txt ]
then
    echo -e "*** WARNING: OVERWRITING EXISTING FILE ***\n"
    rm ${save}.txt
fi

# Detect system and set non-whining environment

sys=`uname`

if [[ "$sys" == 'Darwin' || "$sys" == 'Linux' || "$sys" == 'FreeBSD' ]];
then
    export AFNI_WHEREAMI_NO_WARN=$AFNI_WHEREAMI_NO_WARN:/$HOME/abin
else
    setenv AFNI_WHEREAMI_NO_WARN /$HOME/abin    
fi


# Run

if [ "$output" == 1 ]
then
    prefix=${xcoord}_${ycoord}_${zcoord}
    whereami $xcoord $ycoord $zcoord -max_search_radius 5 -space $space > ${prefix}.txt
else
    whereami $xcoord $ycoord $zcoord -max_search_radius 5 -space $space
fi
