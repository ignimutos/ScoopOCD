$gpu = (Get-CimInstance -ClassName Win32_VideoController).Name
$arch = (Get-Content "$PSScriptRoot\arch.json" | ConvertFrom-Json -AsHashtable).$gpu
debug "gpu: $gpu, arch: $arch"
$hips = (Get-Content "$PSScriptRoot\hip.json" | ConvertFrom-Json -AsHashtable)
$hip_url = ($hips.Keys | Where-Object { $_ -like "*$arch*" } | Select-Object -First 1 | ForEach-Object { $hips.$_ })
debug "download hip file from $hip_url"
if (!$hip_url) {
    error 'for now, your gpu are not supported'
    exit 1
}
Invoke-WebRequest -Uri "$hip_url" -OutFile "$dir\hip.7z"
Expand-7zipArchive "$dir\hip.7z" -DestinationPath "$dir\lib\ollama\rocm" -Removal -Overwrite 'All'
Move-Item "$dir\lib\ollama\rocm\library\*" "$dir\lib\ollama\rocm\rocblas\library\" -Force
Remove-Item "$dir\lib\ollama\rocm\library"
