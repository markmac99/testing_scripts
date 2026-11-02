#!/bin/bash
here="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source <(grep = $here/../pwsh/testing.ini | sed 's/ *= */=/g')

testdir=$(echo $TESTDIR  | tr -d "\n\r" | sed 's|e:|/mnt/e|g')
wmpltest=$(echo $WMPL_TEST  | tr -d "\n\r" | sed 's|e:|/mnt/e|g')
wmplenv=$(echo $WMPL_ENV  | tr -d "\n\r")
wmplloc=$(echo $WMPL_LOC  | tr -d "\n\r" | sed 's|c:|/mnt/c|g')

DATADIR=${testdir}/${wmpltest}/shareddata/

[ "$1" == "" ] && curdir=master || curdir=$1
outdir=${testdir}/${wmpltest}/${curdir}
if [ ! -d $outdir ] ; then echo $curdir doesnt exist ; exit ; fi

cd $outdir
. ~/miniconda3/etc/profile.d/conda.sh
conda activate ${wmplenv}
export PYTHONPATH=${wmplloc}

echo "node1"
echo "  cands     " $(ls -1 ~node1/files/candidates/ | grep -v process | wc -l )
echo "  phase1    " $(ls -1 ~node1/files/phase1/ | grep -v processed | wc -l)
echo "  trajs     " $(ls -1 ~node1/files/trajectories/ | wc -l)
echo ""
echo "node2"
echo "  phase1    " $(ls -1 ~node2/files/phase1/ | grep -v processed | wc -l)
echo "  trajs     " $(ls -1 ~node2/files/trajectories/ | wc -l)
echo ""
echo "parent"
echo "  cands     " $(ls -1 $outdir/candidates/*.pickle | grep -v processed | wc -l)
echo "  processed " $(ls -1 $outdir/candidates/processed/ | wc -l)
echo "  phase1    " $(ls -1 $outdir/phase1/*.pickle | grep -v process | wc -l)
echo "  processed " $(ls -1 $outdir/phase1/processed/  | wc -l)
echo "  trajs     " $(find  $outdir/trajectories -name "*.pickle" -ls  | wc -l)
echo ""
grep Saved $outdir/logs/*cands.log* | egrep -v "Saved 0"
echo ""
ps -ef | grep Correlate | grep -v grep
