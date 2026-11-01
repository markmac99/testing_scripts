#!/bin/bash

here="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ~/miniconda3/etc/profile.d/conda.sh

DATADIR=$HOME/test/wmpl/master/

pushd $DATADIR
conda activate wmpl
export PYTHONPATH=$HOME/src/wmpl_master/

TR="(20260917-120000,20260924-120000)"
python -m wmpl.Trajectory.CorrelateRMS data --mcmode 5 --cpucores 4 --addlogsuffix --logdir $DATADIR/singlepass -r "${TR}" --dbdir $DATADIR --outdir $DATADIR
