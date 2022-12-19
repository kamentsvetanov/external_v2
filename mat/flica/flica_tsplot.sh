#!/bin/bash

if [[ $# == 0 ]]
then
	INFILE=./subjectCoursesOut.txt
else
	INFILE="$1"
fi

if ! test -e $INFILE
then
	echo "File '$INFILE' not found!"
	exit 2
fi

NCOMP=$(grep /NumWaves $INFILE | awk '{print $2}')
NSUBJ=$(grep /NumPoints $INFILE | awk '{print $2}')

echo "Making subject-course images, NCOMP=$NCOMP, NSUBJ=$NSUBJ"
for (( i=0; i < $NCOMP ; i=i+1 ))
do
	echo -n "$i "
	let j=i+1 # i is 0-indexed, j is 1-indexed
	cat $INFILE | grep '^[0-9.-]' | awk '{print $'$j'}' > tmpSubjCourse.txt
	fsl_tsplot -i tmpSubjCourse.txt	-o subjectCourse_$i.png -t "Subject-course for component $i"
done	
echo 'Done.'





