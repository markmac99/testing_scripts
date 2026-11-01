#!/bin/bash

here="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ~/miniconda3/etc/profile.d/conda.sh

OUTDIR=$HOME/test/wmpl/master/
DATADIR=$HOME/test/wmpl/master/data/

cd $OUTDIR
conda activate wmpl
export PYTHONPATH=$HOME/src/wmpl_master/

python -m wmpl.Trajectory.CorrelateRMS $DATADIR --mcmode 1 --cpucores 4 --addlogsuffix -a --autofreq 5 --logdir $OUTDIR/logs --dbdir $OUTDIR --outdir $OUTDIR
