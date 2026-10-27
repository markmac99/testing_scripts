# powershell script to run some basic WMPL tests

# This version does everything ie mcmode 0 or 7, ie standalone mode

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

$targdir="$loc\original"
if (-not (test-path $targdir)) {mkdir $targdir}

if ($args[0] -eq "init")
{
    Write-Output "initialising"
    Push-Location $targdir
    if (test-path processed_trajectories.json){remove-item processed_trajectories.json}
    if (test-path trajectories){remove-item  trajectories -Recurse -Force}
    if (test-path phase1){remove-item  phase1 -Recurse -Force}
    Pop-Location
}else{
    write-output "rerunning"
}

$datadir = "${loc}\clean_run\data"

$tr = "(20260222-170000,20260227-170000)"

python -m wmpl.Trajectory.CorrelateRMS $datadir --cpucores 4 --timerange "${tr}" --logdir $loc/logs --dbdir $targdir --outdir $targdir --maxstations 6 --mcmode 1

$last = (Get-ChildItem $loc/logs | Sort-Object LastWriteTime | Select-Object -last 1)
$bn = ($last.basename)
move-item $last  $loc\logs\${bn}_original.log
set-location $here