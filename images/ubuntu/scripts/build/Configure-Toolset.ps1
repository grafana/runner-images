################################################################################
##  File:  Configure-Toolset.ps1
##  Team:  CI-Build
##  Desc:  Configure toolset
################################################################################

Import-Module "$env:HELPER_SCRIPTS/../tests/Helpers.psm1"

$arch = Get-Architecture

function Get-TCToolVersionPath {
    param(
        [Parameter(Mandatory)]
        [string] $ToolName,
        [Parameter(Mandatory)]
        [string] $ToolVersion,
        [Parameter(Mandatory)]
        [string] $ToolArchitecture
    )

    $toolPath = Join-Path -Path $env:AGENT_TOOLSDIRECTORY -ChildPath $ToolName
    $toolPathVersion = Join-Path -Path $toolPath -ChildPath $ToolVersion
    $foundVersion = Get-Item $toolPathVersion | Sort-Object -Property { [version] $_.name } -Descending | Select-Object -First 1
    if (-not $foundVersion) {
        return $null
    }
    $installationDir = Join-Path -Path $foundVersion -ChildPath $ToolArchitecture

    return $installationDir
}

function Get-TCAssetArchitecture {
    param(
        [Parameter(Mandatory)]
        [PSCustomObject[]] $Assets,
        [Parameter(Mandatory)]
        [PSCustomObject] $Tool,
        [Parameter(Mandatory)]
        [string] $ToolVersion
    )

    if ($arch -eq "amd64") {
        $assetArchs = @("x64", "amd64")
    }

    if ($arch -eq "arm64") {
        $assetArchs = @("arm64", "aarch64")
    }

    $asset = $Assets | Where-Object version -like $ToolVersion `
        | Select-Object -ExpandProperty files `
        | Where-Object { ($_.platform -eq $Tool.platform) -and ($_.platform_version -eq $Tool.platform_version) -and ($assetArchs -contains $_.arch) } `
        | Select-Object -First 1

    if ([string]::IsNullOrEmpty($asset.arch)) {
        Write-Host "Asset for $($tool.name) $toolVersion $($arch) not found in versions manifest"
        return $arch
    } else {
        Write-Host "Asset for $($tool.name) $toolVersion $($arch) found in versions manifest using $($asset.arch)"
        return $asset.arch
    }
}

function Add-GlobalEnvironmentVariable {
    param(
        [Parameter(Mandatory)]
        [string] $Name,
        [Parameter(Mandatory)]
        [string] $Value,
        [string] $FilePath = "/etc/environment"
    )

    $envVar = "{0}={1}" -f $Name, $Value
    Tee-Object -InputObject $envVar -FilePath $FilePath -Append
}

$ErrorActionPreference = "Stop"

Write-Host "Configure toolcache tools environment..."
$toolEnvConfigs = @{
    go = @{
        command          = "ln -s {0}/bin/* /usr/bin/"
        variableTemplate = "GOROOT_{0}_{1}_{2}"
    }
}

# Get toolcache content from toolset
$tools = (Get-ToolsetContent).toolcache | Where-Object { $toolEnvConfigs.Keys -contains $_.name }

foreach ($tool in $tools) {
    $toolEnvConfig = $toolEnvConfigs[$tool.name]

    # If the tool has a url, get the versions manifest
    if ($tool.url) {
        Write-Host "Retrieving assets for $($tool.name)..."
        $assets = Invoke-RestMethod $tool.url
    }

    if (-not ([string]::IsNullOrEmpty($toolEnvConfig.variableTemplate))) {
        foreach ($toolVersion in $tool.versions) {
            Write-Host "Set $($tool.name) $toolVersion environment variable..."
            $toolArch = Get-TCAssetArchitecture -Assets $assets -Tool $tool -ToolVersion $toolVersion
            $toolPath = Get-TCToolVersionPath -ToolName $tool.name -ToolVersion $toolVersion -ToolArchitecture $toolArch
            if (-not $toolPath) {
                Write-Host "Tool $($tool.name) $toolVersion not found in toolcache for $arch"
                continue
            }

            $versionParts = $toolVersion.split(".")
            $envVariableName = $toolEnvConfig.variableTemplate -f $versionParts[0], $versionParts[1], $toolArch.ToUpper()

            Add-GlobalEnvironmentVariable -Name $envVariableName -Value $toolPath
        }
    }

    # Invoke command and add env variable for the default tool version
    if (-not ([string]::IsNullOrEmpty($tool.default))) {
        $toolArch = Get-TCAssetArchitecture -Assets $assets -Tool $tool -ToolVersion $tool.default || $arch
        $toolDefaultPath = Get-TCToolVersionPath -ToolName $tool.name -ToolVersion $tool.default -ToolArchitecture $toolArch
        if (-not $toolDefaultPath) {
            Write-Host "Tool $($tool.name) $($tool.default) not found in toolcache for $arch"
            continue
        }

        if (-not ([string]::IsNullOrEmpty($toolEnvConfig.defaultVariable))) {
            Write-Host "Set default $($toolEnvConfig.defaultVariable) for $($tool.name) $($tool.default) environment variable..."
            Add-GlobalEnvironmentVariable -Name $toolEnvConfig.defaultVariable -Value $toolDefaultPath
        }

        if (-not ([string]::IsNullOrEmpty($toolEnvConfig.command))) {
            $command = $toolEnvConfig.command -f $toolDefaultPath
            Write-Host "Invoke $command command for default $($tool.name) $($tool.default) ..."
            Invoke-Expression -Command $command
        }
    }
}

Invoke-PesterTests -TestFile "Toolset" -TestName "Toolset"
