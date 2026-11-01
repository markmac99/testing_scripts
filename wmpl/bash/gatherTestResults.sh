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
tod=$(date +%Y%m%d)

srcdir=${testdir}/${wmpltest}/master

if [ ! -d $srcdir ] ; then
	echo "sourcedir $srcdir not found"
else
	targdir=$resdir/${tod}/$1
	mkdir -p $targdir

	pushd $srcdir
	python -m wmpl.Trajectory.AggregateAndPlot ./phase1 --skipplots --output $targdir

	if [ -d candidates ] ; then
		cd candidates
		tar cvzf $targdir/candidates_$1.tgz *.pickle processed/*.pickle
		ls -1 *.pickle > $targdir/candidates_$1.csv
		ls -1 processed/*.pickle >> $targdir/candidates_$1.csv
		cd ..
	fi 
	if [ -d phase1 ] ; then
		cd phase1
		tar cvzf $targdir/phase1_$1.tgz *.pickle processed/*.pickle
		ls -1 *.pickle > $targdir/phase1_$1.csv
		ls -1 processed/*.pickle >> $targdir/phase1_$1.csv
		cd ..
	fi 
	if [ -f trajectories.db ] ; then 
		tar cvzf $targdir/databases_$1.tgz *.db
	fi 
	cd logs
	tar cvzf $targdir/logs_$1.tgz *.log
	cd ..
	if [ -d trajectories ] ; then 
		tar cvzf $targdir/trajectories_$1.tgz trajectories/*
	fi
	popd
fi
