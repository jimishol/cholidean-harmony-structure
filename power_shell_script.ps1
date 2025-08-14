# PowerShell script to run LÖVE with console output and restart on exit code 42

$RESTART_CODE = 42

# Path to winpty and Git Bash
$winptyPath = "C:\Program Files\Git\usr\bin\winpty.exe"
$bashPath   = "C:\Program Files\Git\bin\bash.exe"

# Path to love.exe (adjust if needed)
$lovePath = ".\love.exe"

# Check if winpty exists
if (!(Test-Path $winptyPath)) {
    Write-Error "winpty.exe not found at $winptyPath"
    exit 127
}

# Check if bash exists
if (!(Test-Path $bashPath)) {
    Write-Error "bash.exe not found at $bashPath"
    exit 127
}

# Check if love.exe exists
if (!(Test-Path $lovePath)) {
    Write-Error "love.exe not found in current directory"
    exit 127
}

# Loop until exit code is not 42
while ($true) {
    # Launch Git Bash via winpty and run love.exe with --console
    & "$winptyPath" "$bashPath" -c "$lovePath --console ."
    $exitCode = $LASTEXITCODE

    if ($exitCode -eq $RESTART_CODE) {
        Write-Host "Restart requested (exit $exitCode). Relaunching..."
        Start-Sleep -Seconds 0.5
        continue
    } else {
        Write-Host "Exiting (code $exitCode)."
        exit $exitCode
    }
}
