#!/bin/bash

here="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ~/miniconda3/etc/profile.d/conda.sh

DATADIR=$HOME/test/wmpl/master/

pushd $DATADIR
conda activate wmpl
export PYTHONPATH=$HOME/src/wmpl_master/

python -m wmpl.Trajectory.CorrelateRMS data --mcmode 2 --cpucores 2 --addlogsuffix -a --autofreq 5 --logdir $DATADIR/logs --dbdir $DATADIR --outdir $DATADIR
