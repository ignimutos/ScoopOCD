$base_url = ($Manifest.url -split '/', -2)[0]
debug "download rocm file from $base_url/ollama-windows-amd64.7z"
Invoke-WebRequest -Uri "$base_url/ollama-windows-amd64.7z" -OutFile "$dir\rocm.7z"
Expand-7zipArchive "$dir\rocm.7z" -ExtractDir 'windows-amd64' -Removal -Overwrite 'All'

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
Expand-7zipArchive "$dir\hip.7z" -DestinationPath "$env:HIP_PATH\bin" -Removal -Overwrite 'All'
Move-Item "$env:HIP_PATH\bin\library\*" "$env:HIP_PATH\bin\rocblas\library\" -Force
Remove-Item "$env:HIP_PATH\bin\library"
