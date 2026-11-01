#!/bin/bash

here="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. ~/miniconda3/etc/profile.d/conda.sh

DATADIR=$HOME/test/wmpl/shareddata/
OUTDIR=$HOME/test/wmpl/master/

cd $OUTDIR
conda activate wmpl
export PYTHONPATH=$HOME/src/wmpl_master/

python -m wmpl.Trajectory.CorrelateRMS $DATADIR --mcmode 4 --cpucores 4 --addlogsuffix -a 30  --autofreq 5  --logdir $OUTDIR/logs --dbdir $OUTDIR --outdir $OUTDIR
