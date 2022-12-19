#!/bin/bash

SUFFIX=$1

NVERT="$(mri_info *_l$SUFFIX.mgh | grep dimensions: | uniq | sed 's/^[[:space:]]*dimensions:[[:space:]]*//' | sed 's/[[:space:]]*x.*$//')"

case x$NVERT in 
	x)
		FSAV='' 
		exit 1 ;;
	x642)
		FSAV=fsaverage3 ;;
	x2562)
		FSAV=fsaverage4 ;;
	x10242)
		FSAV=fsaverage5 ;;
	x40962)
		FSAV=fsaverage6 ;;
	x163842)
		FSAV=fsaverage ;;
	*)
		echo "Unrecognized (or multiple) #vertices: NVERT='$NVERT'!"
		exit 2
esac


if ! test -d "$FSAVERAGES"
then    FSAVERAGES=~/Downloads/fsaverages/
fi
if ! test -d "$FSAVERAGES"
then    FSAVERAGES=/vols/Data/oslo/fsaverages/
fi
if ! test -d "$FSAVERAGES"
then
        echo "Can't find fsaverages directory: please set FSAVERAGES=/path/to/fsaverages/ before running." 1>&2
        exit 2
fi

for i in fsaverage*; do test -L $i && rm $i; done

ln -s $FSAVERAGES/$FSAV/ $FSAV || (echo "Couldn't create link to '$FSAVERAGES/$FSAV/'!" 1>&2; exit 2)

echo $FSAV

