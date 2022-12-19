
SUFFIX=$1

SRCDIR="${0%/*}/" # path to this executable; assume others in same directory.

echo SRCDIR=$SRCDIR

for FILE in niftiOut_mi?$SUFFIX.nii.gz
do
	echo FILE=$FILE
	MI=$(echo $FILE | sed 's/niftiOut_mi//' | sed 's/[^0-9].*//')
	$SRCDIR/render_lightboxes.sh $FILE _mi$MI
done

