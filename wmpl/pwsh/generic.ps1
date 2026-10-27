# powershell script to run some basic WMPL tests

# This version is the new GMN version with separate steps for candidates and phase1

# load the helper functions
. $PSScriptRoot\helperfunctions.ps1

$ini=get-inicontent "$psscriptroot\testing.ini"

$here = get-location

$wmplloc = $ini['wmpl']['wmpl_loc'].replace('$HOME',$home)
$wmplenv = $ini['wmpl']['wmpl_env']

$testdir = $ini['testing']['testdir'].replace('$HOME',$home)
$wmpltest = $ini['wmpl']['wmpl_test'].replace('$HOME',$home)
#push-location "${testdir}/${wmpltest}"

$loc = get-location

conda activate $wmplenv
$env:pythonpath="$wmplloc;$env:pythonpath"

Push-Location $wmplloc
git checkout distrib_processing
Pop-Location

$targdir="$loc"

if ($args[1] -eq "init")
{
    Write-Output "initialising"
    Push-Location $targdir
    if (test-path observations.db) {remove-item observations.db}
    if (test-path trajectories.db) {remove-item trajectories.db}
    if (test-path processed_trajectories.json){remove-item processed_trajectories.json}
    if (test-path candidates) {remove-item -recurse candidates}
    if (test-path phase1) {remove-item -recurse phase1}
    if (test-path trajectories) {remove-item -recurse trajectories}
    Pop-Location
}else{
    write-output "rerunning"
}

$datadir = "${testdir}/${wmpltest}/shareddata"

$tr = ${args}[0]

python -m wmpl.Trajectory.CorrelateRMS $datadir --cpucores 4 --timerange "${tr}" --logdir $targdir/logs --dbdir $targdir --outdir $targdir --archivemonths 0 --addlogsuffix

set-location $here