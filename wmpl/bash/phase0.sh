#!/bin/bash

here="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source <(grep = $here/../pwsh/testing.ini | sed 's/ *= */=/g')

testdir=$(echo $TESTDIR  | tr -d "\n\r" | sed 's|e:|/mnt/e|g')
wmpltest=$(echo $WMPL_TEST  | tr -d "\n\r" | sed 's|e:|/mnt/e|g')
wmplenv=$(echo $WMPL_ENV  | tr -d "\n\r")
wmplloc=$(echo $WMPL_LOC  | tr -d "\n\r" | sed 's|c:|/mnt/c|g')

DATADIR=${testdir}/${wmpltest}/shareddata/

[ "$1" == "" ] && curdir=master || curdir=$1
OUTDIR=${testdir}/${wmpltest}/${curdir}
if [ ! -d $OUTDIR ] ; then echo $curdir doesnt exist ; exit ; fi

cd $OUTDIR
. ~/miniconda3/etc/profile.d/conda.sh
conda activate ${wmplenv}
export PYTHONPATH=${wmplloc}

python -m wmpl.Trajectory.CorrelateRMS $DATADIR --mcmode 4 --cpucores 4 --addlogsuffix -a 33  --autofreq 5  --logdir $OUTDIR/logs --dbdir $OUTDIR --outdir $OUTDIR
