[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string[]] $TargetPath,

    [switch] $WithParent = $false,

    [bool] $Important = $false
)

# For multi-version, most of app share the same profile by multi-version
if ($Important) {
    $scoop_app_root = Split-Path $dir -Parent
    if ((Get-ChildItem $scoop_app_root -Force | Measure-Object).Count -gt 2) {
        return
    }
}

foreach ($Path in $TargetPath) {
    if (Test-Path $Path) {
        Remove-Item $Path -Recurse -Force -ErrorAction Ignore
    }

    $Parent = Split-Path $Path -Parent
    if ($WithParent -and (Test-Path $Parent)) {
        if ((Get-Item $Parent).TargetPath -or (Get-ChildItem -Path $Parent -Force | Measure-Object).Count -eq 0) {
            Remove-Item -Path $Parent -Recurse -Force -ErrorAction Ignore
        }
    }
}
