Import-Module "$PSScriptRoot/../helpers/Common.Helpers.psm1" -DisableNameChecking

Describe "Java" {
    $arch = (Get-Architecture) -eq "amd64" ? "X64" : "ARM64"
    $toolsetJava = (Get-ToolsetContent).java
    $defaultVersion = $toolsetJava.default
    $jdkVersions = $toolsetJava.versions

    It "Java <DefaultJavaVersion> is default" -TestCases @{ DefaultJavaVersion = $defaultVersion; Arch = $arch } {
        $actualJavaPath = [System.Environment]::GetEnvironmentVariable("JAVA_HOME")
        $expectedJavaPath = [System.Environment]::GetEnvironmentVariable("JAVA_HOME_${DefaultJavaVersion}_${Arch}")

        $actualJavaPath | Should -Not -BeNullOrEmpty
        $expectedJavaPath | Should -Not -BeNullOrEmpty
        $actualJavaPath | Should -Be $expectedJavaPath
    }

    It "<ToolName>" -TestCases @(
        @{ ToolName = "java" }
        @{ ToolName = "javac" }
    ) {
        "$ToolName -version" | Should -ReturnZeroExitCode
    }

    $testCases = $jdkVersions | ForEach-Object { @{Version = $_; Arch = $arch} }

    It "Java <Version>" -TestCases $testCases {
        $javaVariableValue = [System.Environment]::GetEnvironmentVariable("JAVA_HOME_${Version}_${Arch}")
        $javaVariableValue | Should -Not -BeNullOrEmpty
        $javaPath = Join-Path $javaVariableValue "bin/java"

        "`"$javaPath`" -version" | Should -ReturnZeroExitCode

        if ($Version -eq 8) {
            $Version = "1.${Version}"
        }
        "`"$javaPath`" -version" | Should -OutputTextMatchingRegex "openjdk\ version\ `"${Version}(\.[0-9_\.]+)?`""
    }
}

Describe "Java-Tools" {
    It "Gradle" {
        "gradle -version" | Should -ReturnZeroExitCode

        $gradleVariableValue = [System.Environment]::GetEnvironmentVariable("GRADLE_HOME")
        $gradleVariableValue | Should -BeLike "/usr/share/gradle-*"

        $gradlePath = Join-Path $env:GRADLE_HOME "bin/gradle"
        "`"$GradlePath`" -version" | Should -ReturnZeroExitCode
    }
    It "<ToolName>" -TestCases @(
        @{ ToolName = "mvn" }
        @{ ToolName = "ant" }
    ) {
        "$ToolName -version" | Should -ReturnZeroExitCode
    }
}
