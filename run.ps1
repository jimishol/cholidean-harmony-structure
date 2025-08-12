$RESTART_CODE = 42
$localLovePath = Join-Path $PSScriptRoot "love.exe"

# Check if local love.exe exists, otherwise try PATH
if (Test-Path $localLovePath) {
    $love = $localLovePath
} elseif (Get-Command "love" -ErrorAction SilentlyContinue) {
    $love = "love"
} else {
    Write-Host "Error: 'love' executable not found locally or in PATH."
    exit 127
}

do {
    # Launch the game
    Start-Process $love -NoNewWindow -Wait -WorkingDirectory $PSScriptRoot
    $code = $LASTEXITCODE

    if ($code -eq $RESTART_CODE) {
        Write-Host "Restart requested (exit $code). Relaunching..."
        Start-Sleep -Seconds 1
    }
} while ($code -eq $RESTART_CODE)

Write-Host "Exiting (code $code)."
exit $code
