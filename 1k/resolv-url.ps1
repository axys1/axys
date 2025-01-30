# resolve artifact url
param(
    [Alias('artifact')]
    $name,
    $manifest,
    $target,
    $build_id,
    $branch,
    $out_var
)

$artifact_url = $null

if ($manifest -eq 'gcloud') {
    function Get-LatestGoodBuild {
        param (
            [string]$branch,
            [string]$target
        )
    
        $apiURL = "https://androidbuildinternal.googleapis.com/android/internal/build/v3/builds?branches=$([uri]::EscapeDataString($branch))&buildAttemptStatus=complete&buildType=submitted&maxResults=1&successful=true&target=$([uri]::EscapeDataString($target))"
        $body = Invoke-WebRequest -Uri $apiURL
        $buildData = $body | ConvertFrom-Json
        if ($buildData.builds.Count -eq 0) {
            throw "No build ID is found"
        }
        return $buildData.builds[0].buildId
    }
    
    # Validate input parameters
    $artifact = $name
    if (-not $target) { throw "Missing target." }
    if (-not $artifact) { throw "Missing artifact." }
    if (-not $build_id -and -not $branch) { throw "Missing build_id or branch." }
    if (-not $build_id -and $branch) {
        $build_id = Get-LatestGoodBuild -branch $branch -target $target
    }

    $artifact_url = "https://androidbuildinternal.googleapis.com/android/internal/build/v3/builds/$([uri]::EscapeDataString($build_id))/$([uri]::EscapeDataString($target))/attempts/latest/artifacts/$([uri]::EscapeDataString($artifact))/url"
}
else {
    if (Test-Path $manifest -PathType Leaf) {
        $mirror = if (!(Test-Path (Join-Path $PSScriptRoot '.gitee') -PathType Leaf)) { 'github' } else { 'gitee' }

        $manifest_map = ConvertFrom-Json (Get-Content $manifest -raw)
        $ver = $manifest_map.versions.PSObject.Properties[$name].Value
        $mirror_current = $manifest_map.mirrors.PSObject.Properties[$mirror].Value.PSObject.Properties
        $url_base = "https://$($mirror_current['host'].Value)/"
        $url_path = $mirror_current[$name].Value

        $artifact_url = "$url_base$url_path#$ver"
    }
}

if($artifact_url) {
    if(!$out_var) {
        Write-Host $artifact_url -NoNewline
    } else {
        Write-Information $artifact_url -InformationVariable $out_var
    }
}
