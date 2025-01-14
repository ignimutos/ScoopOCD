param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $TargetPath,

    # without $persist_dir
    [string] $PersistPath = ""
)

$PersistDir = "$persist_dir\\$PersistPath"
New-Item $PersistDir -ItemType Directory -ErrorAction Ignore
if (Test-Path $TargetPath) {
    if ((Get-Item $TargetPath -Force).Attributes -match 'ReparsePoint') {
        $child = (Get-ChildItem $TargetPath -Recurse -Force | Select-Object -First 1)
        if ($child) {
            $target = Split-Path $child.FullName -Parent
            if ($target -ne $TargetPath) {
                throw "you already have junction in $TargetPath, please remove it first"
            }
            return
        }
    } else {
        if ((Get-ChildItem $PersistDir -Force | Measure-Object).Count -ne 0) {
            throw "which profile you should use? $TargetPath or $PersistDir"
        }
        Move-Item "$TargetPath\\*" -Destination $PersistDir -Force | Out-Null
    }
}
New-Item $TargetPath -ItemType Junction -Target $PersistDir | Out-Null
