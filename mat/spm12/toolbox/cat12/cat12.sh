#! /bin/bash
# ______________________________________________________________________
#
# Christian Gaser, Robert Dahnke
# Structural Brain Mapping Group (http://www.neuro.uni-jena.de)
# Departments of Neurology and Psychiatry
# Jena University Hospital
# ______________________________________________________________________
# $Id: cat12.sh 1791 2021-04-06 09:15:54Z gaser $
version='cat12.sh $Id: cat12.sh 1791 2021-04-06 09:15:54Z gaser $'

echo "##############################################################"
echo "   cat12.sh is deprecated. Please now use cat_batch_cat.sh.   "
echo "##############################################################"

cat12_dir=$(dirname "$0")
args=("$@")

${cat12_dir}/cat_batch_cat.sh ${args}

