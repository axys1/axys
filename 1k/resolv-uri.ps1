# fetch repo url by name
param(
    $name,
    $manifest_file
)

if(Test-Path $manifest_file -PathType Leaf) {
    $mirror = if (!(Test-Path (Join-Path $PSScriptRoot '.gitee') -PathType Leaf)) {'github'} else {'gitee'}

    $manifest_map = ConvertFrom-Json (Get-Content $manifest_file -raw)
    $ver = $manifest_map.versions.PSObject.Properties[$name].Value
    $mirror_current = $manifest_map.mirrors.PSObject.Properties[$mirror].Value.PSObject.Properties
    $url_base = "https://$($mirror_current['host'].Value)/"
    $url_path = $mirror_current[$name].Value

    Write-Host "$url_base$url_path#$ver" -NoNewline
}
