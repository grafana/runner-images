function Get-ToolcacheRubyVersions {
    $toolcachePath = Join-Path $env:AGENT_TOOLSDIRECTORY "Ruby"
    if (-not (Test-Path $toolcachePath)) {
        return @()
    }
    return Get-ChildItem $toolcachePath -Name | Sort-Object { [Version] $_ }
}

function Get-ToolcachePythonVersions {
    $toolcachePath = Join-Path $env:AGENT_TOOLSDIRECTORY "Python"
    if (-not (Test-Path $toolcachePath)) {
        return @()
    }
    return Get-ChildItem $toolcachePath -Name | Sort-Object { [Version] $_ }
}

function Get-ToolcachePyPyVersions {
    $toolcachePath = Join-Path $env:AGENT_TOOLSDIRECTORY "PyPy"
    if (-not (Test-Path $toolcachePath)) {
        return @()
    }
    Get-ChildItem -Path $toolcachePath -Name | Sort-Object { [Version] $_ } | ForEach-Object {
        $pypyRootPath = Join-Path $toolcachePath $_ $(Get-Architecture)
        [string] $pypyVersionOutput = & "$pypyRootPath/bin/python" -c "import sys;print(sys.version)"
        $pypyVersionOutput -match "^([\d\.]+) \(.+\) \[PyPy ([\d\.]+\S*) .+]$" | Out-Null
        return "{0} [PyPy {1}]" -f $Matches[1], $Matches[2]
    }
}

function Get-ToolcacheNodeVersions {
    $toolcachePath = Join-Path $env:AGENT_TOOLSDIRECTORY "node"
    if (-not (Test-Path $toolcachePath)) {
        return @()
    }
    return Get-ChildItem $toolcachePath -Name | Sort-Object { [Version] $_ }
}

function Get-ToolcacheGoVersions {
    $toolcachePath = Join-Path $env:AGENT_TOOLSDIRECTORY "go"
    if (-not (Test-Path $toolcachePath)) {
        return @()
    }
    return Get-ChildItem $toolcachePath -Name | Sort-Object { [Version] $_ }
}
