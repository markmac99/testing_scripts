#!/bin/bash

echo "node1"
echo "  cands     " $(ls -1 ~node1/files/candidates/*.pickle | grep -v process | wc -l )
echo "  phase1    " $(ls -1 ~node1/files/phase1/ | grep -v processed | wc -l)
echo "  trajs     " $(ls -1 ~node1/files/trajectories/ | wc -l)
echo ""
echo "node2"
echo "  phase1    " $(ls -1 ~node2/files/phase1/ | grep -v processed | wc -l)
echo "  trajs     " $(ls -1 ~node2/files/trajectories/ | wc -l)
echo ""
echo "parent"
echo "  cands     " $(ls -1 candidates/ | grep -v processed | wc -l)
echo "  processed " $(ls -1 candidates/processed/ | wc -l)
echo "  phase1    " $(ls -1 phase1/ | grep -v process | wc -l)
echo "  processed " $(ls -1 phase1/processed  | wc -l)
echo "  trajs     " $(find trajectories -name "*.pickle" -ls  | wc -l)
echo ""
grep Saved logs/*cands.log* | egrep -v "Saved 0"
echo ""
ps -ef | grep Correlate | grep -v grep
