#!/bin/bash
here="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source <(grep = $here/../pwsh/testing.ini | sed 's/ *= */=/g')

testdir=$(echo $TESTDIR  | tr -d "\n\r" | sed 's|e:|/mnt/e|g')
wmpltest=$(echo $WMPL_TEST  | tr -d "\n\r" | sed 's|e:|/mnt/e|g')
wmplenv=$(echo $WMPL_ENV  | tr -d "\n\r")
wmplloc=$(echo $WMPL_LOC  | tr -d "\n\r" | sed 's|c:|/mnt/c|g')
datadir=${testdir}/${wmpltest}/newdata

source ~/.bashrc
eval "$(conda shell.bash hook)"
source ~/miniconda3/bin/activate ${wmplenv}

export PYTHONPATH=${wmplloc}

echo "generating report, pythonpath is $PYTHONPATH"
python -m wmpl.Trajectory.AggregateAndPlot ./trajectories --output ./plots --skipplots

echo "done"
