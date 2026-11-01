#!/bin/bash

here="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source <(grep = $here/../pwsh/testing.ini | sed 's/ *= */=/g')

testdir=$(echo $TESTDIR  | tr -d "\n\r" | sed 's|e:|/mnt/e|g')
wmpltest=$(echo $WMPL_TEST  | tr -d "\n\r" | sed 's|e:|/mnt/e|g')
wmplenv=$(echo $WMPL_ENV  | tr -d "\n\r")
wmplloc=$(echo $WMPL_LOC  | tr -d "\n\r" | sed 's|c:|/mnt/c|g')

DATADIR=${testdir}/${wmpltest}/shareddata/
OUTDIR=${testdir}/${wmpltest}/master

cd $OUTDIR
. ~/miniconda3/etc/profile.d/conda.sh
conda activate ${wmplenv}
export PYTHONPATH=${wmplloc}

[ "$1" == "" ] && TR="(20260917-120000,20260924-120000)" || TR="$1"
echo $TR
sleep 30
python -m wmpl.Trajectory.CorrelateRMS $DATADIR --mcmode 5 --cpucores 4 --addlogsuffix --logdir $OUTDIR/logs -r "${TR}" --dbdir $OUTDIR --outdir $OUTDIR
