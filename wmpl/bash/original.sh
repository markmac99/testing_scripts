#!/bin/bash

here="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source <(grep = $here/../pwsh/testing.ini | sed 's/ *= */=/g')

testdir=$(echo $TESTDIR  | tr -d "\n\r" | sed 's|e:|/mnt/e|g')
wmpltest=$(echo $WMPL_TEST  | tr -d "\n\r" | sed 's|e:|/mnt/e|g')
wmplenv=$(echo $WMPL_ENV  | tr -d "\n\r")
wmplloc=$(echo $OLD_WMPL_LOC  | tr -d "\n\r" | sed 's|c:|/mnt/c|g')

DATADIR=${testdir}/${wmpltest}/shareddata/

[ "$2" == "" ] && curdir=master || curdir=$2
OUTDIR=${testdir}/${wmpltest}/${curdir}
if [ ! -d $OUTDIR ] ; then echo $curdir doesnt exist ; exit ; fi

cd $OUTDIR
. ~/miniconda3/etc/profile.d/conda.sh
conda activate ${wmplenv}
export PYTHONPATH=${wmplloc}

[ "$1" == "" ] && TR="(20261005-010757,20261104-120232)" || TR="$1"
python -m wmpl.Trajectory.CorrelateRMS $DATADIR --mcmode 1 --cpucores 4 --logdir $OUTDIR/orig -r "${TR}" --dbdir $OUTDIR --outdir $OUTDIR
