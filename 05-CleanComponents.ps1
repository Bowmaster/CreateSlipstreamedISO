$OSVersion = (Get-WmiObject -Class "Win32_OperatingSystem").Version

if ($OSVersion.StartsWith("10.")) {
    Write-Host "Cleaning up and reseting the component store, this will take a while. Please ensure this is only done once all Windows updates are installed" -ForegroundColor Yellow
    Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase
    Write-Host "Finished cleaning up and reseting the component store, the Server will reboot in 30 seconds" -ForegroundColor Green
} elseif ($OSVersion.StartsWith("6.1.")) {
    Write-Host "Using the Server 2008R2 cleanup process." -ForegroundColor Yellow
    .\UtilityScripts\cleanup-disk.ps1
    Write-Host "Finished cleaning up and reseting the component store, the Server will reboot in 30 seconds" -ForegroundColor Green
}
Start-Sleep -Seconds 30
Restart-Computer -Force