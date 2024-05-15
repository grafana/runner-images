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
Write-Output '$softwareReport.Root.AddToolVersion("OS Version:", $(Get-OSVersionFull))'
$softwareReport.Root.AddToolVersion("Kernel Version:", $(Get-KernelVersion))
Write-Output '$softwareReport.Root.AddToolVersion("Kernel Version:", $(Get-KernelVersion))'
$softwareReport.Root.AddToolVersion("Image Version:", $env:IMAGE_VERSION)
Write-Output '$softwareReport.Root.AddToolVersion("Image Version:", $env:IMAGE_VERSION)'
$softwareReport.Root.AddToolVersion("Systemd version:", $(Get-SystemdVersion))
Write-Output '$softwareReport.Root.AddToolVersion("Systemd version:", $(Get-SystemdVersion))'

$installedSoftware = $softwareReport.Root.AddHeader("Installed Software")

# Language and Runtime
$languageAndRuntime = $installedSoftware.AddHeader("Language and Runtime")
$languageAndRuntime.AddToolVersion("Bash", $(Get-BashVersion))
Write-Output '$languageAndRuntime.AddToolVersion("Bash", $(Get-BashVersion))'
$languageAndRuntime.AddToolVersionsListInline("Clang", $(Get-ClangToolVersions -ToolName "clang"), "^\d+")
Write-Output '$languageAndRuntime.AddToolVersionsListInline("Clang", $(Get-ClangToolVersions -ToolName "clang"), "^\d+")'
$languageAndRuntime.AddToolVersionsListInline("Clang-format", $(Get-ClangToolVersions -ToolName "clang-format"), "^\d+")
Write-Output '$languageAndRuntime.AddToolVersionsListInline("Clang-format", $(Get-ClangToolVersions -ToolName "clang-format"), "^\d+")'
$languageAndRuntime.AddToolVersionsListInline("Clang-tidy", $(Get-ClangTidyVersions), "^\d+")
Write-Output '$languageAndRuntime.AddToolVersionsListInline("Clang-tidy", $(Get-ClangTidyVersions), "^\d+")'
$languageAndRuntime.AddToolVersion("Dash", $(Get-DashVersion))
Write-Output '$languageAndRuntime.AddToolVersion("Dash", $(Get-DashVersion))'
if (Test-IsUbuntu20) {
    $languageAndRuntime.AddToolVersion("Erlang", $(Get-ErlangVersion))
    Write-Output '$languageAndRuntime.AddToolVersion("Erlang", $(Get-ErlangVersion))'
    $languageAndRuntime.AddToolVersion("Erlang rebar3", $(Get-ErlangRebar3Version))
    Write-Output '$languageAndRuntime.AddToolVersion("Erlang rebar3", $(Get-ErlangRebar3Version))'
}
$languageAndRuntime.AddToolVersionsListInline("GNU C++", $(Get-CPPVersions), "^\d+")
Write-Output '$languageAndRuntime.AddToolVersionsListInline("GNU C++", $(Get-CPPVersions), "^\d+")'
$languageAndRuntime.AddToolVersionsListInline("GNU Fortran", $(Get-FortranVersions), "^\d+")
Write-Output '$languageAndRuntime.AddToolVersionsListInline("GNU Fortran", $(Get-FortranVersions), "^\d+")'
$languageAndRuntime.AddToolVersion("Julia", $(Get-JuliaVersion))
Write-Output '$languageAndRuntime.AddToolVersion("Julia", $(Get-JuliaVersion))'
$languageAndRuntime.AddToolVersion("Kotlin", $(Get-KotlinVersion))
Write-Output '$languageAndRuntime.AddToolVersion("Kotlin", $(Get-KotlinVersion))'
$languageAndRuntime.AddToolVersion("Mono", $(Get-MonoVersion))
Write-Output '$languageAndRuntime.AddToolVersion("Mono", $(Get-MonoVersion))'
$languageAndRuntime.AddToolVersion("MSBuild", $(Get-MsbuildVersion))
Write-Output '$languageAndRuntime.AddToolVersion("MSBuild", $(Get-MsbuildVersion))'
$languageAndRuntime.AddToolVersion("Node.js", $(Get-NodeVersion))
Write-Output '$languageAndRuntime.AddToolVersion("Node.js", $(Get-NodeVersion))'
$languageAndRuntime.AddToolVersion("Perl", $(Get-PerlVersion))
Write-Output '$languageAndRuntime.AddToolVersion("Perl", $(Get-PerlVersion))'
$languageAndRuntime.AddToolVersion("Python", $(Get-PythonVersion))
Write-Output '$languageAndRuntime.AddToolVersion("Python", $(Get-PythonVersion))'
$languageAndRuntime.AddToolVersion("Ruby", $(Get-RubyVersion))
Write-Output '$languageAndRuntime.AddToolVersion("Ruby", $(Get-RubyVersion))'
$languageAndRuntime.AddToolVersion("Swift", $(Get-SwiftVersion))
Write-Output '$languageAndRuntime.AddToolVersion("Swift", $(Get-SwiftVersion))'

# Package Management
$packageManagement = $installedSoftware.AddHeader("Package Management")
$packageManagement.AddToolVersion("cpan", $(Get-CpanVersion))
Write-Output '$packageManagement.AddToolVersion("cpan", $(Get-CpanVersion))'
$packageManagement.AddToolVersion("Helm", $(Get-HelmVersion))
Write-Output '$packageManagement.AddToolVersion("Helm", $(Get-HelmVersion))'
if (Test-IsAmd64) {
    $packageManagement.AddToolVersion("Homebrew", $(Get-HomebrewVersion))
    Write-Output '$packageManagement.AddToolVersion("Homebrew", $(Get-HomebrewVersion))'
}
$packageManagement.AddToolVersion("Miniconda", $(Get-MinicondaVersion))
Write-Output '$packageManagement.AddToolVersion("Miniconda", $(Get-MinicondaVersion))'
$packageManagement.AddToolVersion("Npm", $(Get-NpmVersion))
Write-Output '$packageManagement.AddToolVersion("Npm", $(Get-NpmVersion))'
$packageManagement.AddToolVersion("NuGet", $(Get-NuGetVersion))
Write-Output '$packageManagement.AddToolVersion("NuGet", $(Get-NuGetVersion))'
$packageManagement.AddToolVersion("Pip", $(Get-PipVersion))
Write-Output '$packageManagement.AddToolVersion("Pip", $(Get-PipVersion))'
$packageManagement.AddToolVersion("Pip3", $(Get-Pip3Version))
Write-Output '$packageManagement.AddToolVersion("Pip3", $(Get-Pip3Version))'
$packageManagement.AddToolVersion("Pipx", $(Get-PipxVersion))
Write-Output '$packageManagement.AddToolVersion("Pipx", $(Get-PipxVersion))'
$packageManagement.AddToolVersion("RubyGems", $(Get-GemVersion))
Write-Output '$packageManagement.AddToolVersion("RubyGems", $(Get-GemVersion))'
$packageManagement.AddToolVersion("Vcpkg", $(Get-VcpkgVersion))
Write-Output '$packageManagement.AddToolVersion("Vcpkg", $(Get-VcpkgVersion))'
$packageManagement.AddToolVersion("Yarn", $(Get-YarnVersion))
Write-Output '$packageManagement.AddToolVersion("Yarn", $(Get-YarnVersion))'
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
if (Test-IsUbuntu20) {
    $projectManagement.AddToolVersion("Ant", $(Get-AntVersion))
    Write-Output '$projectManagement.AddToolVersion("Ant", $(Get-AntVersion))'
    $projectManagement.AddToolVersion("Gradle", $(Get-GradleVersion))
    Write-Output '$projectManagement.AddToolVersion("Gradle", $(Get-GradleVersion))'
}
if ((Test-IsUbuntu20) -or (Test-IsUbuntu22)) {
    $projectManagement.AddToolVersion("Lerna", $(Get-LernaVersion))
    Write-Output '$projectManagement.AddToolVersion("Lerna", $(Get-LernaVersion))'
}
$projectManagement.AddToolVersion("Maven", $(Get-MavenVersion))
Write-Output '$projectManagement.AddToolVersion("Maven", $(Get-MavenVersion))'
if (Test-IsUbuntu20) {
    $projectManagement.AddToolVersion("Sbt", $(Get-SbtVersion))
    Write-Output '$projectManagement.AddToolVersion("Sbt", $(Get-SbtVersion))'
}

# Tools
$tools = $installedSoftware.AddHeader("Tools")
$tools.AddToolVersion("Ansible", $(Get-AnsibleVersion))
Write-Output '$tools.AddToolVersion("Ansible", $(Get-AnsibleVersion))'
# TODO: Fix retrieval of apt-fast version on Software Report
# $tools.AddToolVersion("apt-fast", $(Get-AptFastVersion))
# Write-Output '$tools.AddToolVersion("apt-fast", $(Get-AptFastVersion))'
$tools.AddToolVersion("AzCopy", $(Get-AzCopyVersion))
Write-Output '$tools.AddToolVersion("AzCopy", $(Get-AzCopyVersion))'
$tools.AddToolVersion("Bazel", $(Get-BazelVersion))
Write-Output '$tools.AddToolVersion("Bazel", $(Get-BazelVersion))'
$tools.AddToolVersion("Bazelisk", $(Get-BazeliskVersion))
Write-Output '$tools.AddToolVersion("Bazelisk", $(Get-BazeliskVersion))'
$tools.AddToolVersion("Bicep", $(Get-BicepVersion))
Write-Output '$tools.AddToolVersion("Bicep", $(Get-BicepVersion))'
$tools.AddToolVersion("Buildah", $(Get-BuildahVersion))
Write-Output '$tools.AddToolVersion("Buildah", $(Get-BuildahVersion))'
$tools.AddToolVersion("CMake", $(Get-CMakeVersion))
Write-Output '$tools.AddToolVersion("CMake", $(Get-CMakeVersion))'
if (Test-IsAmd64) {
    $tools.AddToolVersion("CodeQL Action Bundle", $(Get-CodeQLBundleVersion))
    Write-Output '$tools.AddToolVersion("CodeQL Action Bundle", $(Get-CodeQLBundleVersion))'
}
$tools.AddToolVersion("Docker Amazon ECR Credential Helper", $(Get-DockerAmazonECRCredHelperVersion))
Write-Output '$tools.AddToolVersion("Docker Amazon ECR Credential Helper", $(Get-DockerAmazonECRCredHelperVersion))'
$tools.AddToolVersion("Docker Compose v2", $(Get-DockerComposeV2Version))
Write-Output '$tools.AddToolVersion("Docker Compose v2", $(Get-DockerComposeV2Version))'
$tools.AddToolVersion("Docker-Buildx", $(Get-DockerBuildxVersion))
Write-Output '$tools.AddToolVersion("Docker-Buildx", $(Get-DockerBuildxVersion))'
$tools.AddToolVersion("Docker Client", $(Get-DockerClientVersion))
Write-Output '$tools.AddToolVersion("Docker Client", $(Get-DockerClientVersion))'
$tools.AddToolVersion("Docker Server", $(Get-DockerServerVersion))
Write-Output '$tools.AddToolVersion("Docker Server", $(Get-DockerServerVersion))'
if ((Test-IsUbuntu20) -or (Test-IsUbuntu22)) {
    $tools.AddToolVersion("Fastlane", $(Get-FastlaneVersion))
    Write-Output '$tools.AddToolVersion("Fastlane", $(Get-FastlaneVersion))'
}
$tools.AddToolVersion("Git", $(Get-GitVersion))
Write-Output '$tools.AddToolVersion("Git", $(Get-GitVersion))'
$tools.AddToolVersion("Git LFS", $(Get-GitLFSVersion))
Write-Output '$tools.AddToolVersion("Git LFS", $(Get-GitLFSVersion))'
$tools.AddToolVersion("Git-ftp", $(Get-GitFTPVersion))
Write-Output '$tools.AddToolVersion("Git-ftp", $(Get-GitFTPVersion))'
$tools.AddToolVersion("Haveged", $(Get-HavegedVersion))
Write-Output '$tools.AddToolVersion("Haveged", $(Get-HavegedVersion))'
if (Test-IsAmd64) {
    $tools.AddToolVersion("Heroku", $(Get-HerokuVersion))
    Write-Output '$tools.AddToolVersion("Heroku", $(Get-HerokuVersion))'
}
if (Test-IsUbuntu20) {
    $tools.AddToolVersion("HHVM (HipHop VM)", $(Get-HHVMVersion))
    Write-Output '$tools.AddToolVersion("HHVM (HipHop VM)", $(Get-HHVMVersion))'
}
$tools.AddToolVersion("jq", $(Get-JqVersion))
Write-Output '$tools.AddToolVersion("jq", $(Get-JqVersion))'
$tools.AddToolVersion("Kind", $(Get-KindVersion))
Write-Output '$tools.AddToolVersion("Kind", $(Get-KindVersion))'
$tools.AddToolVersion("Kubectl", $(Get-KubectlVersion))
Write-Output '$tools.AddToolVersion("Kubectl", $(Get-KubectlVersion))'
$tools.AddToolVersion("Kustomize", $(Get-KustomizeVersion))
Write-Output '$tools.AddToolVersion("Kustomize", $(Get-KustomizeVersion))'
$tools.AddToolVersion("Leiningen", $(Get-LeiningenVersion))
Write-Output '$tools.AddToolVersion("Leiningen", $(Get-LeiningenVersion))'
$tools.AddToolVersion("MediaInfo", $(Get-MediainfoVersion))
Write-Output '$tools.AddToolVersion("MediaInfo", $(Get-MediainfoVersion))'
$tools.AddToolVersion("Mercurial", $(Get-HGVersion))
Write-Output '$tools.AddToolVersion("Mercurial", $(Get-HGVersion))'
$tools.AddToolVersion("Minikube", $(Get-MinikubeVersion))
Write-Output '$tools.AddToolVersion("Minikube", $(Get-MinikubeVersion))'
$tools.AddToolVersion("n", $(Get-NVersion))
Write-Output '$tools.AddToolVersion("n", $(Get-NVersion))'
$tools.AddToolVersion("Newman", $(Get-NewmanVersion))
Write-Output '$tools.AddToolVersion("Newman", $(Get-NewmanVersion))'
$tools.AddToolVersion("nvm", $(Get-NvmVersion))
Write-Output '$tools.AddToolVersion("nvm", $(Get-NvmVersion))'
$tools.AddToolVersion("OpenSSL", $(Get-OpensslVersion))
Write-Output '$tools.AddToolVersion("OpenSSL", $(Get-OpensslVersion))'
$tools.AddToolVersion("Packer", $(Get-PackerVersion))
Write-Output '$tools.AddToolVersion("Packer", $(Get-PackerVersion))'
$tools.AddToolVersion("Parcel", $(Get-ParcelVersion))
Write-Output '$tools.AddToolVersion("Parcel", $(Get-ParcelVersion))'
if (Test-IsUbuntu20) {
    $tools.AddToolVersion("PhantomJS", $(Get-PhantomJSVersion))
    Write-Output '$tools.AddToolVersion("PhantomJS", $(Get-PhantomJSVersion))'
}
$tools.AddToolVersion("Podman", $(Get-PodManVersion))
Write-Output '$tools.AddToolVersion("Podman", $(Get-PodManVersion))'
$tools.AddToolVersion("Pulumi", $(Get-PulumiVersion))
Write-Output '$tools.AddToolVersion("Pulumi", $(Get-PulumiVersion))'
if (Test-IsAmd64) {
    $tools.AddToolVersion("R", $(Get-RVersion))
    Write-Output '$tools.AddToolVersion("R", $(Get-RVersion))'
}
$tools.AddToolVersion("Skopeo", $(Get-SkopeoVersion))
Write-Output '$tools.AddToolVersion("Skopeo", $(Get-SkopeoVersion))'
$tools.AddToolVersion("Sphinx Open Source Search Server", $(Get-SphinxVersion))
Write-Output '$tools.AddToolVersion("Sphinx Open Source Search Server", $(Get-SphinxVersion))'
$tools.AddToolVersion("SVN", $(Get-SVNVersion))
Write-Output '$tools.AddToolVersion("SVN", $(Get-SVNVersion))'
$tools.AddToolVersion("Terraform", $(Get-TerraformVersion))
Write-Output '$tools.AddToolVersion("Terraform", $(Get-TerraformVersion))'
$tools.AddToolVersion("yamllint", $(Get-YamllintVersion))
Write-Output '$tools.AddToolVersion("yamllint", $(Get-YamllintVersion))'
$tools.AddToolVersion("yq", $(Get-YqVersion))
Write-Output '$tools.AddToolVersion("yq", $(Get-YqVersion))'
$tools.AddToolVersion("zstd", $(Get-ZstdVersion))
Write-Output '$tools.AddToolVersion("zstd", $(Get-ZstdVersion))'

# CLI Tools
$cliTools = $installedSoftware.AddHeader("CLI Tools")
$cliTools.AddToolVersion("Alibaba Cloud CLI", $(Get-AlibabaCloudCliVersion))
Write-Output '$cliTools.AddToolVersion("Alibaba Cloud CLI", $(Get-AlibabaCloudCliVersion))'
$cliTools.AddToolVersion("AWS CLI", $(Get-AWSCliVersion))
Write-Output '$cliTools.AddToolVersion("AWS CLI", $(Get-AWSCliVersion))'
$cliTools.AddToolVersion("AWS CLI Session Manager Plugin", $(Get-AWSCliSessionManagerPluginVersion))
Write-Output '$cliTools.AddToolVersion("AWS CLI Session Manager Plugin", $(Get-AWSCliSessionManagerPluginVersion))'
$cliTools.AddToolVersion("AWS SAM CLI", $(Get-AWSSAMVersion))
Write-Output '$cliTools.AddToolVersion("AWS SAM CLI", $(Get-AWSSAMVersion))'
$cliTools.AddToolVersion("Azure CLI", $(Get-AzureCliVersion))
Write-Output '$cliTools.AddToolVersion("Azure CLI", $(Get-AzureCliVersion))'
$cliTools.AddToolVersion("Azure CLI (azure-devops)", $(Get-AzureDevopsVersion))
Write-Output '$cliTools.AddToolVersion("Azure CLI (azure-devops)", $(Get-AzureDevopsVersion))'
$cliTools.AddToolVersion("GitHub CLI", $(Get-GitHubCliVersion))
Write-Output '$cliTools.AddToolVersion("GitHub CLI", $(Get-GitHubCliVersion))'
$cliTools.AddToolVersion("Google Cloud CLI", $(Get-GoogleCloudCLIVersion))
Write-Output '$cliTools.AddToolVersion("Google Cloud CLI", $(Get-GoogleCloudCLIVersion))'
$cliTools.AddToolVersion("Netlify CLI", $(Get-NetlifyCliVersion))
Write-Output '$cliTools.AddToolVersion("Netlify CLI", $(Get-NetlifyCliVersion))'
$cliTools.AddToolVersion("OpenShift CLI", $(Get-OCCliVersion))
Write-Output '$cliTools.AddToolVersion("OpenShift CLI", $(Get-OCCliVersion))'
$cliTools.AddToolVersion("ORAS CLI", $(Get-ORASCliVersion))
Write-Output '$cliTools.AddToolVersion("ORAS CLI", $(Get-ORASCliVersion))'
$cliTools.AddToolVersion("Vercel CLI", $(Get-VerselCliversion))
Write-Output '$cliTools.AddToolVersion("Vercel CLI", $(Get-VerselCliversion))'

$installedSoftware.AddHeader("Java").AddTable($(Get-JavaVersionsTable))

$phpTools = $installedSoftware.AddHeader("PHP Tools")
$phpTools.AddToolVersionsListInline("PHP", $(Get-PHPVersions), "^\d+\.\d+")
Write-Output '$phpTools.AddToolVersionsListInline("PHP", $(Get-PHPVersions), "^\d+\.\d+")'
$phpTools.AddToolVersion("Composer", $(Get-ComposerVersion))
Write-Output '$phpTools.AddToolVersion("Composer", $(Get-ComposerVersion))'
$phpTools.AddToolVersion("PHPUnit", $(Get-PHPUnitVersion))
Write-Output '$phpTools.AddToolVersion("PHPUnit", $(Get-PHPUnitVersion))'
$phpTools.AddNote("Both Xdebug and PCOV extensions are installed, but only Xdebug is enabled.")

$haskellTools = $installedSoftware.AddHeader("Haskell Tools")
$haskellTools.AddToolVersion("Cabal", $(Get-CabalVersion))
Write-Output '$haskellTools.AddToolVersion("Cabal", $(Get-CabalVersion))'
$haskellTools.AddToolVersion("GHC", $(Get-GHCVersion))
Write-Output '$haskellTools.AddToolVersion("GHC", $(Get-GHCVersion))'
$haskellTools.AddToolVersion("GHCup", $(Get-GHCupVersion))
Write-Output '$haskellTools.AddToolVersion("GHCup", $(Get-GHCupVersion))'
$haskellTools.AddToolVersion("Stack", $(Get-StackVersion))
Write-Output '$haskellTools.AddToolVersion("Stack", $(Get-StackVersion))'

Initialize-RustEnvironment
$rustTools = $installedSoftware.AddHeader("Rust Tools")
$rustTools.AddToolVersion("Cargo", $(Get-CargoVersion))
Write-Output '$rustTools.AddToolVersion("Cargo", $(Get-CargoVersion))'
$rustTools.AddToolVersion("Rust", $(Get-RustVersion))
Write-Output '$rustTools.AddToolVersion("Rust", $(Get-RustVersion))'
$rustTools.AddToolVersion("Rustdoc", $(Get-RustdocVersion))
Write-Output '$rustTools.AddToolVersion("Rustdoc", $(Get-RustdocVersion))'
$rustTools.AddToolVersion("Rustup", $(Get-RustupVersion))
Write-Output '$rustTools.AddToolVersion("Rustup", $(Get-RustupVersion))'
$rustToolsPackages = $rustTools.AddHeader("Packages")
$rustToolsPackages.AddToolVersion("Bindgen", $(Get-BindgenVersion))
Write-Output '$rustToolsPackages.AddToolVersion("Bindgen", $(Get-BindgenVersion))'
$rustToolsPackages.AddToolVersion("Cargo audit", $(Get-CargoAuditVersion))
Write-Output '$rustToolsPackages.AddToolVersion("Cargo audit", $(Get-CargoAuditVersion))'
$rustToolsPackages.AddToolVersion("Cargo clippy", $(Get-CargoClippyVersion))
Write-Output '$rustToolsPackages.AddToolVersion("Cargo clippy", $(Get-CargoClippyVersion))'
$rustToolsPackages.AddToolVersion("Cargo outdated", $(Get-CargoOutdatedVersion))
Write-Output '$rustToolsPackages.AddToolVersion("Cargo outdated", $(Get-CargoOutdatedVersion))'
$rustToolsPackages.AddToolVersion("Cbindgen", $(Get-CbindgenVersion))
Write-Output '$rustToolsPackages.AddToolVersion("Cbindgen", $(Get-CbindgenVersion))'
$rustToolsPackages.AddToolVersion("Rustfmt", $(Get-RustfmtVersion))
Write-Output '$rustToolsPackages.AddToolVersion("Rustfmt", $(Get-RustfmtVersion))'

$browsersTools = $installedSoftware.AddHeader("Browsers and Drivers")
if (Test-IsAmd64) {
    $browsersTools.AddToolVersion("Google Chrome", $(Get-ChromeVersion))
    Write-Output '$browsersTools.AddToolVersion("Google Chrome", $(Get-ChromeVersion))'
    $browsersTools.AddToolVersion("ChromeDriver", $(Get-ChromeDriverVersion))
    Write-Output '$browsersTools.AddToolVersion("ChromeDriver", $(Get-ChromeDriverVersion))'
    $browsersTools.AddToolVersion("Chromium", $(Get-ChromiumVersion))
    Write-Output '$browsersTools.AddToolVersion("Chromium", $(Get-ChromiumVersion))'
    $browsersTools.AddToolVersion("Microsoft Edge", $(Get-EdgeVersion))
    Write-Output '$browsersTools.AddToolVersion("Microsoft Edge", $(Get-EdgeVersion))'
    $browsersTools.AddToolVersion("Microsoft Edge WebDriver", $(Get-EdgeDriverVersion))
    Write-Output '$browsersTools.AddToolVersion("Microsoft Edge WebDriver", $(Get-EdgeDriverVersion))'
}
$browsersTools.AddToolVersion("Selenium server", $(Get-SeleniumVersion))
Write-Output '$browsersTools.AddToolVersion("Selenium server", $(Get-SeleniumVersion))'
$browsersTools.AddToolVersion("Mozilla Firefox", $(Get-FirefoxVersion))
Write-Output '$browsersTools.AddToolVersion("Mozilla Firefox", $(Get-FirefoxVersion))'
$browsersTools.AddToolVersion("Geckodriver", $(Get-GeckodriverVersion))
Write-Output '$browsersTools.AddToolVersion("Geckodriver", $(Get-GeckodriverVersion))'
$browsersTools.AddHeader("Environment variables").AddTable($(Build-BrowserWebdriversEnvironmentTable))

$netCoreTools = $installedSoftware.AddHeader(".NET Tools")
$netCoreTools.AddToolVersionsListInline(".NET Core SDK", $(Get-DotNetCoreSdkVersions), "^\d+\.\d+\.\d")
Write-Output '$netCoreTools.AddToolVersionsListInline(".NET Core SDK", $(Get-DotNetCoreSdkVersions), "^\d+\.\d+\.\d")'
$netCoreTools.AddNodes($(Get-DotnetTools))

$databasesTools = $installedSoftware.AddHeader("Databases")
if (Test-IsUbuntu20) {
    $databasesTools.AddToolVersion("MongoDB", $(Get-MongoDbVersion))
    Write-Output '$databasesTools.AddToolVersion("MongoDB", $(Get-MongoDbVersion))'
}
$databasesTools.AddToolVersion("sqlite3", $(Get-SqliteVersion))
Write-Output '$databasesTools.AddToolVersion("sqlite3", $(Get-SqliteVersion))'
$databasesTools.AddNode($(Build-PostgreSqlSection))
$databasesTools.AddNode($(Build-MySQLSection))
$databasesTools.AddNode($(Build-MSSQLToolsSection))

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

$powerShellTools = $installedSoftware.AddHeader("PowerShell Tools")
$powerShellTools.AddToolVersion("PowerShell", $(Get-PowershellVersion))
Write-Output '$powerShellTools.AddToolVersion("PowerShell", $(Get-PowershellVersion))'
$powerShellTools.AddHeader("PowerShell Modules").AddNodes($(Get-PowerShellModules))
Write-Output '$powerShellTools.AddHeader("PowerShell Modules").AddNodes($(Get-PowerShellModules))'

$installedSoftware.AddHeader("Web Servers").AddTable($(Build-WebServersTable))
Write-Output '$installedSoftware.AddHeader("Web Servers").AddTable($(Build-WebServersTable))'

$androidTools = $installedSoftware.AddHeader("Android")
Write-Output '$androidTools = $installedSoftware.AddHeader("Android")'
$androidTools.AddTable($(Build-AndroidTable))
Write-Output '$androidTools.AddTable($(Build-AndroidTable))'
$androidTools.AddHeader("Environment variables").AddTable($(Build-AndroidEnvironmentTable))
Write-Output '$androidTools.AddHeader("Environment variables").AddTable($(Build-AndroidEnvironmentTable))'

$installedSoftware.AddHeader("Cached Docker images").AddTable($(Get-CachedDockerImagesTableData))
Write-Output '$installedSoftware.AddHeader("Cached Docker images").AddTable($(Get-CachedDockerImagesTableData))'
$installedSoftware.AddHeader("Installed apt packages").AddTable($(Get-AptPackages))
Write-Output '$installedSoftware.AddHeader("Installed apt packages").AddTable($(Get-AptPackages))'

$softwareReport.ToJson() | Out-File -FilePath "${OutputDirectory}/software-report.json" -Encoding UTF8NoBOM
$softwareReport.ToMarkdown() | Out-File -FilePath "${OutputDirectory}/software-report.md" -Encoding UTF8NoBOM
