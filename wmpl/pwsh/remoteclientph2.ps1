# powershell script to run some basic WMPL tests

# This version does loads remote candidates and performs phase 2 solns then uploads the results

Param($config='testing.ini')

# load the helper functions
. $PSScriptRoot\helperfunctions.ps1

$ini=get-inicontent "$psscriptroot\$config"

$here = get-location

$testdir = $ini['testing']['testdir'].replace('$HOME',$home)
$wmplloc = $ini['wmpl']['wmpl_loc'].replace('$HOME',$home)
$wmplenv = $ini['wmpl']['wmpl_env']
$wmpltest = $ini['wmpl']['wmpl_test'].replace('$HOME',$home)

push-location "${testdir}/${wmpltest}"
$loc = get-location

conda activate $wmplenv
$env:pythonpath="$wmplloc;$env:pythonpath"

Push-Location $wmplloc
git checkout distrib_processing
Pop-Location

$targdir="$loc\remoteph2"
if (-not (test-path $targdir)) {mkdir $targdir}
if ((test-path $targdir\trajectories)) {rmdir -r $targdir\trajectories}
if ((test-path $targdir\phase1)) {rmdir -r $targdir\phase1}
if ((test-path $targdir\candidates)) {rmdir -r $targdir\candidates}

$datadir = "${targdir}\data"
if (-not (test-path $datadir)) {mkdir $datadir}

#copy $PSScriptRoot\wmpl_remote_ph2.cfg $targdir\wmpl_remote.cfg

# dont use maxtraj as it interferes with master/child data management
python -m wmpl.Trajectory.CorrelateRMS $datadir -a --autofreq 5 --mcmode 2 --cpucores 4 --logdir $targdir/logs --outdir $targdir --dbdir $targdir --addlogsuffix

cd $here
