# cleanup runtime trash
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $ConfigPath,

    # INI section without [] brackets
    [Parameter(Mandatory = $true)]
    [array] $PropPath,

    [ValidateSet("json", "ini")]
    [string] $Type,

    [bool] $Value = $false
)

$ConfigPath = "$persist_dir\$ConfigPath"

if (!$Type) {
    $Type = [System.IO.Path]::GetExtension($ConfigPath).TrimStart('.').ToLower()
}
switch ($Type) {
    "json" {
        if (Test-Path $ConfigPath) {
            $data = Get-Content -Path $ConfigPath | ConvertFrom-Json -AsHashtable
        } else {
            $data = @{}
        }
        $cur = $data
        $len = $PropPath.Length
        for ($i = 0; $i -lt $len; $i++) {
            $prop = $PropPath[$i]
            if ($i -lt ($len - 1)) {
                if (!$cur.ContainsKey($prop)) {
                    $cur[$prop] = @{}
                }
            } else {
                $cur[$prop] = $Value
                break
            }
            $cur = $cur[$prop]
        }
        $data | ConvertTo-Json | Set-Content -Path $ConfigPath -Force
    }
    "ini" {
        if ($PropPath.Length -ne 2) {
            Write-Error "INI type only support 2 path element"
            return
        }
        $section = $PropPath[0]
        $prop = $PropPath[1]
        if (Test-Path $ConfigPath) {
            $data = Get-Content -Path $ConfigPath -Raw
            $regex = "(?<=\[$section\][\s\S]*?$prop=)[^\r\n]*"
            if ($data -match $regex) {
                $data = $data -replace $regex, $Value
            } else {
                # seems software use ini config always use bottom value with same section and name, so add it to the bottom
                $data += "`r`n`[$section`]`r`n$prop=$Value"
            }
        } else {
            $data = "[$section]`r`n$prop=$Value"
        }
        $data | Set-Content -Path $ConfigPath -Force
    }
    Default {
        throw 'unknown type to process'
    }
}
