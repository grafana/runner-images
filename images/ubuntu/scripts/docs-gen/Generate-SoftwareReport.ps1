using module ./software-report-base/SoftwareReport.psm1
using module ./software-report-base/SoftwareReport.Nodes.psm1

param (
    [Parameter(Mandatory)]
    [string] $OutputDirectory
)

$global:ErrorActionPreference = "Stop"
$global:ErrorView = "NormalView"
Set-StrictMode -Version Latest

Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Android.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Browsers.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.CachedTools.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Common.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Databases.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Helpers.psm1") -DisableNameChecking
Import-Module "$PSScriptRoot/../helpers/Common.Helpers.psm1" -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Java.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Rust.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Tools.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.WebServers.psm1") -DisableNameChecking

# Restore file owner in user profile
sudo chown -R ${env:USER}: $env:HOME

# Software report
$softwareReport = [SoftwareReport]::new("Ubuntu $(Get-OSVersionShort)")
$softwareReport.Root.AddToolVersion("OS Version:", $(Get-OSVersionFull))
$softwareReport.Root.AddToolVersion("Kernel Version:", $(Get-KernelVersion))
$softwareReport.Root.AddToolVersion("Image Version:", $env:IMAGE_VERSION)
$softwareReport.Root.AddToolVersion("Systemd version:", $(Get-SystemdVersion))

$installedSoftware = $softwareReport.Root.AddHeader("Installed Software")

# Language and Runtime
$languageAndRuntime = $installedSoftware.AddHeader("Language and Runtime")
$languageAndRuntime.AddToolVersion("Bash", $(Get-BashVersion))
$languageAndRuntime.AddToolVersionsListInline("Clang", $(Get-ClangToolVersions -ToolName "clang"), "^\d+")
$languageAndRuntime.AddToolVersionsListInline("Clang-format", $(Get-ClangToolVersions -ToolName "clang-format"), "^\d+")
$languageAndRuntime.AddToolVersionsListInline("Clang-tidy", $(Get-ClangTidyVersions), "^\d+")
$languageAndRuntime.AddToolVersion("Dash", $(Get-DashVersion))
$languageAndRuntime.AddToolVersionsListInline("GNU C++", $(Get-CPPVersions), "^\d+")
$languageAndRuntime.AddToolVersionsListInline("GNU Fortran", $(Get-FortranVersions), "^\d+")
$languageAndRuntime.AddToolVersion("Julia", $(Get-JuliaVersion))
$languageAndRuntime.AddToolVersion("Kotlin", $(Get-KotlinVersion))
if (-not $(Test-IsUbuntu24)) {
    $languageAndRuntime.AddToolVersion("Mono", $(Get-MonoVersion))
    $languageAndRuntime.AddToolVersion("MSBuild", $(Get-MsbuildVersion))
}
$languageAndRuntime.AddToolVersion("Node.js", $(Get-NodeVersion))
$languageAndRuntime.AddToolVersion("Perl", $(Get-PerlVersion))
$languageAndRuntime.AddToolVersion("Python", $(Get-PythonVersion))
$languageAndRuntime.AddToolVersion("Ruby", $(Get-RubyVersion))
$languageAndRuntime.AddToolVersion("Swift", $(Get-SwiftVersion))


# Package Management
$packageManagement = $installedSoftware.AddHeader("Package Management")
$packageManagement.AddToolVersion("cpan", $(Get-CpanVersion))
# TODO: Fix helm version retrieval on Software Report
# $packageManagement.AddToolVersion("Helm", $(Get-HelmVersion))
if (Test-IsAmd64) {
    $packageManagement.AddToolVersion("Homebrew", $(Get-HomebrewVersion))
}
$packageManagement.AddToolVersion("Miniconda", $(Get-MinicondaVersion))
$packageManagement.AddToolVersion("Npm", $(Get-NpmVersion))
if (-not $(Test-IsUbuntu24)) {
    $packageManagement.AddToolVersion("NuGet", $(Get-NuGetVersion))
}
$packageManagement.AddToolVersion("Pip", $(Get-PipVersion))
$packageManagement.AddToolVersion("Pip3", $(Get-Pip3Version))
$packageManagement.AddToolVersion("Pipx", $(Get-PipxVersion))
$packageManagement.AddToolVersion("RubyGems", $(Get-GemVersion))
$packageManagement.AddToolVersion("Vcpkg", $(Get-VcpkgVersion))
$packageManagement.AddToolVersion("Yarn", $(Get-YarnVersion))
$packageManagement.AddHeader("Environment variables").AddTable($(Build-PackageManagementEnvironmentTable))
if (Test-IsAmd64) {
    $packageManagement.AddHeader("Homebrew note").AddNote(@'
Location: /home/linuxbrew
Note: Homebrew is pre-installed on image but not added to PATH.
run the eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" command
to accomplish this.
'@)
}

# Project Management
$projectManagement = $installedSoftware.AddHeader("Project Management")
$projectManagement.AddToolVersion("Ant", $(Get-AntVersion))
$projectManagement.AddToolVersion("Gradle", $(Get-GradleVersion))
$projectManagement.AddToolVersion("Lerna", $(Get-LernaVersion))
$projectManagement.AddToolVersion("Maven", $(Get-MavenVersion))
if (Test-IsUbuntu22) {
    $projectManagement.AddToolVersion("Sbt", $(Get-SbtVersion))
}

# Tools
$tools = $installedSoftware.AddHeader("Tools")
$tools.AddToolVersion("Ansible", $(Get-AnsibleVersion))
if (Test-IsUbuntu22) {
    # TODO: Fix retrieval of apt-fast version on Software Report
    # $tools.AddToolVersion("apt-fast", $(Get-AptFastVersion))
}
$tools.AddToolVersion("AzCopy", $(Get-AzCopyVersion))
$tools.AddToolVersion("Bazel", $(Get-BazelVersion))
$tools.AddToolVersion("Bazelisk", $(Get-BazeliskVersion))
$tools.AddToolVersion("Bicep", $(Get-BicepVersion))
$tools.AddToolVersion("Buildah", $(Get-BuildahVersion))
$tools.AddToolVersion("CMake", $(Get-CMakeVersion))
if (Test-IsAmd64) {
    $tools.AddToolVersion("CodeQL Action Bundle", $(Get-CodeQLBundleVersion))
}
$tools.AddToolVersion("Docker Amazon ECR Credential Helper", $(Get-DockerAmazonECRCredHelperVersion))
$tools.AddToolVersion("Docker Compose v2", $(Get-DockerComposeV2Version))
$tools.AddToolVersion("Docker-Buildx", $(Get-DockerBuildxVersion))
$tools.AddToolVersion("Docker Client", $(Get-DockerClientVersion))
$tools.AddToolVersion("Docker Server", $(Get-DockerServerVersion))
$tools.AddToolVersion("Fastlane", $(Get-FastlaneVersion))
$tools.AddToolVersion("Git", $(Get-GitVersion))
$tools.AddToolVersion("Git LFS", $(Get-GitLFSVersion))
$tools.AddToolVersion("Git-ftp", $(Get-GitFTPVersion))
$tools.AddToolVersion("Haveged", $(Get-HavegedVersion))
if (Test-IsAmd64) {
    if (Test-IsUbuntu22) {
        $tools.AddToolVersion("Heroku", $(Get-HerokuVersion))
    }
}
$tools.AddToolVersion("jq", $(Get-JqVersion))
$tools.AddToolVersion("Kind", $(Get-KindVersion))
$tools.AddToolVersion("Kubectl", $(Get-KubectlVersion))
$tools.AddToolVersion("Kustomize", $(Get-KustomizeVersion))
if (Test-IsUbuntu22) {
    $tools.AddToolVersion("Leiningen", $(Get-LeiningenVersion))
}
$tools.AddToolVersion("MediaInfo", $(Get-MediainfoVersion))
$tools.AddToolVersion("Mercurial", $(Get-HGVersion))
$tools.AddToolVersion("Minikube", $(Get-MinikubeVersion))
$tools.AddToolVersion("n", $(Get-NVersion))
$tools.AddToolVersion("Newman", $(Get-NewmanVersion))
$tools.AddToolVersion("nvm", $(Get-NvmVersion))
$tools.AddToolVersion("OpenSSL", $(Get-OpensslVersion))
$tools.AddToolVersion("Packer", $(Get-PackerVersion))
$tools.AddToolVersion("Parcel", $(Get-ParcelVersion))
$tools.AddToolVersion("Podman", $(Get-PodManVersion))
$tools.AddToolVersion("Pulumi", $(Get-PulumiVersion))
if (Test-IsAmd64) {
    if (Test-IsUbuntu22) {
        $tools.AddToolVersion("R", $(Get-RVersion))
    }
}
$tools.AddToolVersion("Skopeo", $(Get-SkopeoVersion))
$tools.AddToolVersion("Sphinx Open Source Search Server", $(Get-SphinxVersion))
if (Test-IsUbuntu22) {
    $tools.AddToolVersion("SVN", $(Get-SVNVersion))
    $tools.AddToolVersion("Terraform", $(Get-TerraformVersion))
}
$tools.AddToolVersion("yamllint", $(Get-YamllintVersion))
$tools.AddToolVersion("yq", $(Get-YqVersion))
$tools.AddToolVersion("zstd", $(Get-ZstdVersion))
$tools.AddToolVersion("Ninja", $(Get-NinjaVersion))

# CLI Tools
$cliTools = $installedSoftware.AddHeader("CLI Tools")
if (Test-IsUbuntu22) {
    $cliTools.AddToolVersion("Alibaba Cloud CLI", $(Get-AlibabaCloudCliVersion))
}
$cliTools.AddToolVersion("AWS CLI", $(Get-AWSCliVersion))
$cliTools.AddToolVersion("AWS CLI Session Manager Plugin", $(Get-AWSCliSessionManagerPluginVersion))
$cliTools.AddToolVersion("AWS SAM CLI", $(Get-AWSSAMVersion))
$cliTools.AddToolVersion("Azure CLI", $(Get-AzureCliVersion))
$cliTools.AddToolVersion("Azure CLI (azure-devops)", $(Get-AzureDevopsVersion))
$cliTools.AddToolVersion("GitHub CLI", $(Get-GitHubCliVersion))
$cliTools.AddToolVersion("Google Cloud CLI", $(Get-GoogleCloudCLIVersion))
if (Test-IsUbuntu22) {
    $cliTools.AddToolVersion("Netlify CLI", $(Get-NetlifyCliVersion))
    $cliTools.AddToolVersion("OpenShift CLI", $(Get-OCCliVersion))
    $cliTools.AddToolVersion("ORAS CLI", $(Get-ORASCliVersion))
    $cliTools.AddToolVersion("Vercel CLI", $(Get-VerselCliversion))
}

# Java
$installedSoftware.AddHeader("Java").AddTable($(Get-JavaVersionsTable))

# PHP Tools
$phpTools = $installedSoftware.AddHeader("PHP Tools")
$phpTools.AddToolVersionsListInline("PHP", $(Get-PHPVersions), "^\d+\.\d+")
$phpTools.AddToolVersion("Composer", $(Get-ComposerVersion))
$phpTools.AddToolVersion("PHPUnit", $(Get-PHPUnitVersion))
$phpTools.AddNote("Both Xdebug and PCOV extensions are installed, but only Xdebug is enabled.")

# Haskell Tools
$haskellTools = $installedSoftware.AddHeader("Haskell Tools")
$haskellTools.AddToolVersion("Cabal", $(Get-CabalVersion))
$haskellTools.AddToolVersion("GHC", $(Get-GHCVersion))
if (Test-IsAmd64) {
    $haskellTools.AddToolVersion("GHCup", $(Get-GHCupVersion))
}
$haskellTools.AddToolVersion("Stack", $(Get-StackVersion))

# Rust Tools
Initialize-RustEnvironment
$rustTools = $installedSoftware.AddHeader("Rust Tools")
$rustTools.AddToolVersion("Cargo", $(Get-CargoVersion))
$rustTools.AddToolVersion("Rust", $(Get-RustVersion))
$rustTools.AddToolVersion("Rustdoc", $(Get-RustdocVersion))
$rustTools.AddToolVersion("Rustup", $(Get-RustupVersion))

# Packages
$rustToolsPackages = $rustTools.AddHeader("Packages")
if (Test-IsUbuntu22) {
    $rustToolsPackages.AddToolVersion("Bindgen", $(Get-BindgenVersion))
    $rustToolsPackages.AddToolVersion("Cargo audit", $(Get-CargoAuditVersion))
    $rustToolsPackages.AddToolVersion("Cargo clippy", $(Get-CargoClippyVersion))
    $rustToolsPackages.AddToolVersion("Cargo outdated", $(Get-CargoOutdatedVersion))
    $rustToolsPackages.AddToolVersion("Cbindgen", $(Get-CbindgenVersion))
}
$rustToolsPackages.AddToolVersion("Rustfmt", $(Get-RustfmtVersion))

# Browsers and Drivers
$browsersTools = $installedSoftware.AddHeader("Browsers and Drivers")
if (Test-IsAmd64) {
    $browsersTools.AddToolVersion("Google Chrome", $(Get-ChromeVersion))
    $browsersTools.AddToolVersion("ChromeDriver", $(Get-ChromeDriverVersion))
    $browsersTools.AddToolVersion("Chromium", $(Get-ChromiumVersion))
    $browsersTools.AddToolVersion("Microsoft Edge", $(Get-EdgeVersion))
    $browsersTools.AddToolVersion("Microsoft Edge WebDriver", $(Get-EdgeDriverVersion))
}
$browsersTools.AddToolVersion("Selenium server", $(Get-SeleniumVersion))
$browsersTools.AddToolVersion("Mozilla Firefox", $(Get-FirefoxVersion))
$browsersTools.AddToolVersion("Geckodriver", $(Get-GeckodriverVersion))


# Environment variables
$browsersTools.AddHeader("Environment variables").AddTable($(Build-BrowserWebdriversEnvironmentTable))

# .NET Tools
$netCoreTools = $installedSoftware.AddHeader(".NET Tools")
$netCoreTools.AddToolVersionsListInline(".NET Core SDK", $(Get-DotNetCoreSdkVersions), "^\d+\.\d+\.\d+")
$netCoreTools.AddNodes($(Get-DotnetTools))

# Databases
$databasesTools = $installedSoftware.AddHeader("Databases")
$databasesTools.AddToolVersion("sqlite3", $(Get-SqliteVersion))
$databasesTools.AddNode($(Build-PostgreSqlSection))
$databasesTools.AddNode($(Build-MySQLSection))
if (-not $(Test-IsUbuntu24)) {
    $databasesTools.AddNode($(Build-MSSQLToolsSection))
}

# Cached Tools
$cachedTools = $installedSoftware.AddHeader("Cached Tools")
$goVersions = Get-ToolcacheGoVersions
if ($goVersions) {
    $cachedTools.AddToolVersionsList("Go", $($goVersions), "^\d+\.\d+")
}
$nodeVersions = Get-ToolcacheNodeVersions
if ($nodeVersions) {
    $cachedTools.AddToolVersionsList("Node.js", $($nodeVersions), "^\d+")
}
$pythonVersions = Get-ToolcachePythonVersions
if ($pythonVersions) {
    $cachedTools.AddToolVersionsList("Python", $($pythonVersions), "^\d+\.\d+")
}
$pypyVersions = Get-ToolcachePyPyVersions
if ($pypyVersions) {
    $cachedTools.AddToolVersionsList("PyPy", $($pypyVersions), "^\d+\.\d+")
}
$rubyVersions = Get-ToolcacheRubyVersions
if ($rubyVersions) {
    $cachedTools.AddToolVersionsList("Ruby", $($rubyVersions), "^\d+\.\d+")
}

# PowerShell Tools
$powerShellTools = $installedSoftware.AddHeader("PowerShell Tools")
$powerShellTools.AddToolVersion("PowerShell", $(Get-PowershellVersion))
$powerShellTools.AddHeader("PowerShell Modules").AddNodes($(Get-PowerShellModules))

$installedSoftware.AddHeader("Web Servers").AddTable($(Build-WebServersTable))

$androidTools = $installedSoftware.AddHeader("Android")
$androidTools.AddTable($(Build-AndroidTable))

$androidTools.AddHeader("Environment variables").AddTable($(Build-AndroidEnvironmentTable))

if (-not $(Test-IsUbuntu24)) {
    $installedSoftware.AddHeader("Cached Docker images").AddTable($(Get-CachedDockerImagesTableData))
}
$installedSoftware.AddHeader("Installed apt packages").AddTable($(Get-AptPackages))

$softwareReport.ToJson() | Out-File -FilePath "${OutputDirectory}/software-report.json" -Encoding UTF8NoBOM
$softwareReport.ToMarkdown() | Out-File -FilePath "${OutputDirectory}/software-report.md" -Encoding UTF8NoBOM
