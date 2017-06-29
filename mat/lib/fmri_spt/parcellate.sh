#(c) 2012, Ameera X. Patel, University of Cambridge

tempdir=$HOME/fmri_spt/templates/standard
parcdir=$HOME/fmri_spt/templates/parcel_temps
codedir=$HOME/fmri_spt/code_bin
maskdir=$HOME/fmri_spt/templates/mask
basedir=`pwd`

usage()
{
cat<<EOF
usage: $0 options

===========================================================================

fMRI SIGNAL PROCESSING TOOLBOX v.1.1
Parcellate.sh 

(c) Ameera X. Patel, 2012


Parcellates functional datasets in using an anatomical parcellation 
template.


This script carries out two functions:

A.  Converts functional and anatomical datasets from native to standard
    talairach space. The input dataset MUST be in native space.

    Output 1 = Talairached anatomical dataset (appends suffix _at to
               dataset name)
    Output 2 = Talairached functional dataset (appends suffix _at to
               dataset name)
    Output 3 = directory 'tlrc_log' with talairach log files.

B.  Applies an anatomical parcellation template of your choice to your 
    functional dataset and outputs regional time series.

    Output 3 = Average time series for each parcel (cols=parcels, 
               rows=frames). Appends _ts.txt to output file name.
    Output 4 = Number of voxels in each parcel (col1=parcel#, 
               col2=#voxels). Appends _n.txt to output file name.
    Output 5 = Centroid coordinates for each parcel (cols=parcel#, 
               row1=x, row2=y, row3=z). Appends _xyz.txt to output 
               file name.
    Output 6 = The parcellation template used and resampled template.

    NOTE,
    The input functional and anatomical datasets MUST be in
    native space, not standard space. If the functional datasets
    are already in standard space, then this program will not work.


OPTIONS:

    -h  Show this message (Flag)
    -i  Pre-processed functional dataset (in native space) [REQUIRED]
    -a  Pre-processed anatomical dataset (in native space) [REQUIRED]
    -t  Stanard space template, in talairach space. THIS MUST BE ONE OF 
        THE FOLLOWING 4 OPTIONS (MNI,N27, ICBM, EPI). [DEFAULT="MNI"]
        Please see below for more information on templates.
    -p  Parcellation template. Please select one template from the 
        /templates/atlas folder in this package. [DEFAULT="AT116.nii"]
        More information on parcellation templates below.
    -o  Output prefix for parcellated data. Note, this program will
        append extensions onto this name [DEFAULT="ppp"]
    -v  Verbose (Flag)

    
    A note on standard space template options:

    -t  N27     This is based on the "Colin brain" scanned 27 times and
                averaged.
        MNI     This is the standard Montreal Neurological Institute (MNI)
                template - average of 152 normal brains. T1 weighted 
                template has been used to optimise mapping.
        ICBM    This is the 'International Consortium for Brain Mapping'
                (ICBM) template - average of 452 normal brains.
        EPI     This is the EPI template from spm.

        ***     RECOMMENDATION - the MNI and N27 templates work well. If 
                warping does not converge with one template, and you 
                find some unexpected intermediate files in your working
                directory, please try a different template. A number of
                features relating to the way the data has been acquired
                can cause \@auto_tlrc to fail.


    A note on parcellation template options:
    
    The following options are available with v1.0 of this package. These
    parcellation templates are based on one of the afni atlases.
    (TT_N27_EZ_ML). 
    
    -p  AT116.nii   (anatomical parcellation)
        AT150.nii   (150 regions)
        AT230.nii   (230 regions)
        AT325.nii   (325 regions)
        SP638.nii   (638 regions)

    These parcellation templates will work well with all of the standard 
    space template options listed above (N27, MNI, ICBM and EPI). These 
    templates are good for most purposes, but if you require a custom-made
    template, please email.


    A note on coordinates:

    The coordinates output are talairach coordinates. Orientation is RAI.


    E.g.  bash ~/fmri_spt/parcellate.sh -i rest_pp.nii.gz -a 
          mprage_ns.nii.gz -p AT230.nii -t N27 -o ppp

    will output: rest_pp_at+tlrc, mprage_ns_at.nii, ppp_ts.txt, ppp_n.txt,
                 ppp_xyz.txt into the working directory, along with the log
                 directory, tlrc_log.


============================================================================

EOF
}

input=
anat=
temp=
parcel=
output=
verbose=

while getopts "hi:a:t:p:o:v" OPTION
do
    case $OPTION in
    h)  
        usage
        exit 1
        ;; 
    i)
        input=$OPTARG
        ;;
    a)
        anat=$OPTARG
        ;;
    t)
        temp=$OPTARG
        ;;
    p)
        parcel=$OPTARG
        ;;
    o)
        output=$OPTARG
        ;;
    v)
        verbose=1
        ;;
    ?)
        usage
        exit
        ;;
    esac
done

# Verbose option

if [ "$verbose" == 1 ]
then
    set -x verbose
fi

if [[ -z $input ]] || [[ -z $anat ]]
then
    usage
    exit 1
fi

# Set defaults if options empty

if [ "$temp" == "" ]
then
    temp=MNI
fi

if [ "$output" == "" ]
then
    output=ppp
fi

if [ "$parcel" == "" ]
then
    parcel=AT116.nii
fi

# Fail safe to prevent script execution with non-existent files.

echo ""
echo "Checking functional and anatomical datasets ..."
echo ""

if [ -f $input ];
then
    echo "Functional dataset ok"
else
    echo "Cannot locate file $input. Please ensure the $input dataset is in this directory"
    exit 1
fi

if [ -f $anat ];
then
    echo "Anatomical dataset ok"
    echo ""
else
    echo "Cannot locate file $anat. Please ensure the file $anat is in the working directory"
    exit 1
fi

cd ${parcdir}
echo "Checking parcellation template ..."
echo ""

if [ -f $parcel ];
then
    echo "Parcellation template ok"
    echo ""
else
    echo "Parcellation template not found."
    echo ""
    echo "Please select a parcellation template from the parcellation templates provided in this package. Please see $parcdir for options. To view the help file enter parcellate.sh -h "
    echo ""
    exit 1
fi

cd ${basedir}

# Calculate voxel size and string tokenize variables

voxi=`3dinfo -adi ${input}`
voxj=`3dinfo -adj ${input}`
voxk=`3dinfo -adk ${input}`

if [[ $voxj < $voxi ]]; then s=$voxj; else s=$voxi; fi
if [[ $voxk < $s ]]; then s=$voxk; fi

inpstr=${input%%.*}
anatstr=${anat%%.*}
parcstr=${parcel%%.*}

# Convert standard space template inputs to fname strings

if [[ "$temp" =~ "N27" ]]
then
    tempstr='TT_N27+tlrc'
    maskstr='TT_N27_csf_mask.nii.gz'
fi

if [[ "$temp" =~ "MNI" ]]
then
    tempstr='TT_avg152T1+tlrc'
    maskstr='TT_avg152T1_csf_mask.nii.gz'
fi

if [[ "$temp" =~ "ICBM" ]]
then
    tempstr='TT_icbm452+tlrc'
    maskstr='TT_icbm452_csf_mask.nii.gz'
fi

if [[ "$temp" =~ "EPI" ]]
then
    tempstr='TT_EPI+tlrc'
    maskstr='TT_EPI_csf_mask.nii.gz'
fi

# Fail safe in case incorrect standard space templates are entered

if [[ "$temp" == "N27" || "$temp" == "MNI" || "$temp" == "EPI" || "$temp" == "ICBM" ]]
then
    echo ""
    echo "Warping to talairach space using the $tempstr template brain ... "
    echo "To view this template, please see $tempdir "
    echo ""
else
    echo ""
    echo "Standard space template '${temp}' not found. Please enter one of the following options: N27, MNI, ICMB, EPI."
    echo "For more information, please see the help file (bash parcellate.sh -h) "
    echo ""

    exit
fi

# Warp functional and anatomical datasets to talairach space

echo "Creating log directory ..."

\@auto_tlrc -suffix _at -base ${tempdir}/${tempstr} -input ${anat} -no_ss -ok_notice
adwarp -prefix ./${inpstr}_at -dxyz ${s} -apar ${anatstr}_at.nii -dpar ${input} -force

if [ -d "tlrc_log" ]
then
    echo ""
else
    mkdir tlrc_log
fi

mv ${anatstr}_* ./tlrc_log
cp tlrc_log/${anatstr}_at.nii .


if [ -f ${anatstr}_at.nii ];
then
    echo ""
    echo "+++++++++++++++++++++++++++++++++++++++"
else
    echo "Anatomical warping failed to converge. Please check input anatomical dataset is not already in standard space"
fi

if [ -f ${inpstr}_at+tlrc.BRIK ];
then
    echo "+++++++++++++++++++++++++++++++++++++++"
else
    echo "Functional dataset warping failed to converge. Please re-try parcellation with a different standard space template"
fi


# Resample parcellation template from anatomical to functional resolution

echo ""
echo "Resampling parcellation template to functional resolution"
echo ""

voxia=`3dinfo -adi ${inpstr}_at+tlrc`
voxja=`3dinfo -adj ${inpstr}_at+tlrc`
voxka=`3dinfo -adk ${inpstr}_at+tlrc`

cp ${parcdir}/${parcel} .

3dresample -overwrite -inset ${parcel} -dxyz ${voxia} ${voxja} ${voxka} -prefix ./${parcstr}_rs.nii.gz -master ${inpstr}_at+tlrc -rmode NN
3dcalc -prefix ./${inpstr}_at_mask -a ./${inpstr}_at+tlrc -expr 'astep(a,0)'
#3dcalc -prefix ./${parcstr}_clipped
3dcalc -prefix ./${parcstr}_clipped -a ./${inpstr}_at_mask+tlrc -b ./${parcstr}_rs.nii.gz -expr 'a*b'

# Calculate number of parcels and time points. Check for degrees of freedom.

np=`3dBrickStat -max -slow ${parcel}`
#tp=`3dinfo -nv ${inpstr}_at+tlrc`

#if [ "$np" -ge "$tp" ]
#then
#    echo ""
#    echo "The number of parcels exceeds the number of time points in your dataset. Please select a different parcellation template. Goodbye. "
#    echo ""
#    exit
#fi

# Find system type

sys=`uname`

# Parcellate functional dataset and concatenate parcel properties depending on system

mkdir parc_log

I_t=""
I_n=""
I_xyz=""

cd parc_log


if [[ "$sys" == 'Darwin' ]]; 
then
    for i in $(jot ${np} 1)
    do  
        3dmaskave -quiet -mask ../${parcstr}_clipped+tlrc -mrange $i $i ../${inpstr}_at+tlrc > _t${i}.1D
        3dBrickStat -count -non-zero -mask ../${parcstr}_clipped+tlrc -mrange $i $i ../${parcstr}_clipped+tlrc[1] > _n${i}.1D
        3dmaskdump -overwrite -xyz -nozero -noijk -mrange $i $i -mask ../${parcstr}_clipped+tlrc ../${parcstr}_clipped+tlrc[1] > _coords${i}.1D
        awk '{sum+=$1}END{print sum/NR}' _coords${i}.1D > x${i}.txt
        awk '{sum+=$2}END{print sum/NR}' _coords${i}.1D > y${i}.txt
        awk '{sum+=$3}END{print sum/NR}' _coords${i}.1D > z${i}.txt
        1dcat x${i}.txt y${i}.txt z${i}.txt > _xyz${i}.1D
        1dtranspose _xyz${i}.1D > __xyz${i}.1D

        I_t="${I_t} _t${i}.1D"
        I_n="${I_n} _n${i}.1D"
        I_xyz="${I_xyz} __xyz${i}.1D"
    done
elif [[ "$sys" == 'Linux' || "$sys" == 'FreeBSD' ]]
then
    for i in $(seq 1 ${np})
    do  
        3dmaskave -quiet -mask ../${parcstr}_clipped+tlrc -mrange $i $i ../${inpstr}_at+tlrc > _t${i}.1D
        3dBrickStat -count -non-zero -mask ../${parcstr}_clipped+tlrc -mrange $i $i ../${parcstr}_clipped+tlrc[1] > _n${i}.1D
        3dmaskdump -overwrite -xyz -nozero -noijk -mrange $i $i -mask ../${parcstr}_clipped+tlrc ../${parcstr}_clipped+tlrc[1] > _coords${i}.1D
        awk '{sum+=$1}END{print sum/NR}' _coords${i}.1D > x${i}.txt
        awk '{sum+=$2}END{print sum/NR}' _coords${i}.1D > y${i}.txt
        awk '{sum+=$3}END{print sum/NR}' _coords${i}.1D > z${i}.txt
        1dcat x${i}.txt y${i}.txt z${i}.txt > _xyz${i}.1D
        1dtranspose _xyz${i}.1D > __xyz${i}.1D

        I_t="${I_t} _t${i}.1D"
        I_n="${I_n} _n${i}.1D"
        I_xyz="${I_xyz} __xyz${i}.1D"
    done
else
    echo "Cannot run parcellation on this operating system."
    exit
fi

matlab -nodisplay -r "compile('$output');quit"

cp ${output}_ts.txt ../
cp ${output}_xyz.txt ../
cp ${output}_n.txt ../

cd ..

#rm -rf parc_log

if [ -f par_error*.txt ];
then
    rm par_error*.txt
fi

# Check parcellation output files present

if [ -f ${output}_ts.txt ];
then
    echo "-------------------------------------------------------------------"
else
    echo "Parcellation failed. Please try again."
    exit 1
fi

if [ -f ${output}_n.txt ];
then
    echo "-------------------------------------------------------------------"
else
    echo "Parcellation failed. Please try again."
    exit 2
fi

if [ -f ${output}_xyz.txt ];
then
    echo "-------------------------------------------------------------------"
else
    echo "Parcellation failed. Please try again."
    exit 3
fi


# Check for zero parcels

python ${codedir}/par_error.py ${output}_ts.txt ${parcstr}

if [ -f par_error_*.txt ];
then
    echo ""
    echo "***************************** WARNING *****************************"
    echo ""
    echo -e "Zero parcels detected. Please check for errors in your dataset \n(e.g. zero-padding, image truncation etc). If the standard space \ntransformation has not worked, please try again using a different \nstandard space template (e.g. MNI)."
    echo -e "Output file 'par_error.txt' into working directory with all parcel \nnumbers containing no time series data"
    echo ""
    echo "*******************************************************************"
    echo ""
else
    echo ""
fi

echo ""
echo -e "Parcellation complete. Parcellated functional dataset ${inputstr}_at.tlrc into ${np}parcels."
echo ""
echo -e "Please check the anatomical, ${anatstr}_at.nii, and functional, ${inpstr}_at+tlrc, \nregistration to standard space using the afni viewer."
echo ""

stty echo
