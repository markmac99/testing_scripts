#!/bin/bash
#
here="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source <(grep = $here/../pwsh/testing.ini | sed 's/ *= */=/g')

testdir=$(echo $TESTDIR  | tr -d "\n\r" | sed 's|e:|/mnt/e|g')
wmpltest=$(echo $WMPL_TEST  | tr -d "\n\r" | sed 's|e:|/mnt/e|g')
wmplenv=$(echo $WMPL_ENV  | tr -d "\n\r")
wmplloc=$(echo $WMPL_LOC  | tr -d "\n\r" | sed 's|c:|/mnt/c|g')
datadir=${testdir}/${wmpltest}/newdata

resdir=${testdir}/${wmpltest}/results
mkdir -p $resdir
cd $resdir
tod=$(date +%Y%m%d-%H$m)

. ~/miniconda3/etc/profile.d/conda.sh
conda activate ${wmplenv}
export PYTHONPATH=${wmplloc}

srcdir=${testdir}/${wmpltest}/master

if [ ! -d $srcdir ] ; then
	echo "sourcedir $srcdir not found"
else
	targdir=$resdir/${tod}
	mkdir -p $targdir

	pushd $srcdir
	python -m wmpl.Trajectory.AggregateAndPlot ./trajectories --skipplots --output $targdir
	if [ "$1" == "" ] ; then 
		[ -d candidates ] && mv candidates $targdir
		[ -d phase1 ] && mv phase1 $targdir
		[ -d trajectories ] && mv trajectories $targdir
		mv *.db $targdir
		mv logs/*.db $targdir
	else
		[ -d candidates ] && cp -pr candidates $targdir
		[ -d phase1 ] && cp -pr phase1 $targdir
		[ -d trajectories ] && cp -pr trajectories $targdir
		cp -pr  *.db $targdir
		cp -pr logs/* $targdir
	fi 
	popd
fi
