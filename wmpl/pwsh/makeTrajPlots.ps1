# powershell script to create the charts from a trajectory pickle

# load the helper functions
. $PSScriptRoot\helperfunctions.ps1

$ini=get-inicontent "$psscriptroot\testing.ini"

$here = get-location

$wmplloc = $ini['wmpl']['wmpl_loc'].replace('$HOME',$home)
$wmplenv = $ini['wmpl']['wmpl_env']

$ukmloc = $ini['ukmon']['ukmon_loc'].replace('$HOME',$home)

conda activate $wmplenv
$env:pythonpath="$wmplloc;$ukmloc;$env:pythonpath"

$targdir = $args[0]
python -m utils.makePlots $targdir

set-location $here