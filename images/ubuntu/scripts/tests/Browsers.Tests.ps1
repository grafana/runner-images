Describe "Firefox" -Skip:((-not (Test-IsUbuntu20)) -and (-not (Test-IsUbuntu22))) {
    It "Firefox" {
        "firefox --version" | Should -ReturnZeroExitCode
    }

    It "Geckodriver" {
        "geckodriver --version" | Should -ReturnZeroExitCode
    }
}

Describe "Chrome" -Skip:(-not (Test-IsAmd64)) {
    It "Chrome" {
        "google-chrome --version" | Should -ReturnZeroExitCode
    }

    Describe "Edge" {
        It "Edge" {
            "microsoft-edge --version" | Should -ReturnZeroExitCode
        }

        It "Edge Driver" {
            "msedgedriver --version" | Should -ReturnZeroExitCode
        }
    }

    It "Chrome and Chrome Driver major versions are the same" {
        $chromeMajor = (google-chrome --version).Trim("Google Chrome ").Split(".")[0]
        $chromeDriverMajor = (chromedriver --version).Trim("ChromeDriver ").Split(".")[0]
        $chromeMajor | Should -BeExactly $chromeDriverMajor
    }
}

Describe "Edge" -Skip:((-not (Test-IsAmd64)) -or ((-not (Test-IsUbuntu20)) -and (-not (Test-IsUbuntu22)))) {
    It "Edge" {
        "microsoft-edge --version" | Should -ReturnZeroExitCode
    }

    It "Edge Driver" {
        "msedgedriver --version" | Should -ReturnZeroExitCode
    }
}

Describe "Chromium" -Skip:(-not (Test-IsAmd64)) {
    It "Chromium" {
        "chromium-browser --version" | Should -ReturnZeroExitCode
    }
}
