$OSVersion = (Get-WmiObject -Class "Win32_OperatingSystem").Version

if ($OSVersion.StartsWith("10.")) {
    Write-Host "Installing drivers for Server 2016" -ForegroundColor Yellow
    pnputil.exe /add-driver ".\HPE-Gen10Array-11-27-2018\SmartPqi.inf"
    pnputil.exe /add-driver ".\VMware-Tools-core-10.3.5-10430147\Drivers\pvscsi\Win8\amd64\pvscsi.inf"
    Write-Host "Finished installing Server 2016 drivers, please check the output below to verify your drivers are installed" -ForegroundColor Green
    pnputil.exe /enum-drivers
} elseif ($OSVersion.StartsWith("6.1")) {
    Write-Host "Installing pvsci drivers only for Server 2008R2" -ForegroundColor Yellow
    pnputil.exe -a ".\VMware-Tools-core-10.3.5-10430147\Drivers\pvscsi\Vista\amd64\pvscsi.inf"
    Write-Host "Finished installing Server 2008R2 drivers, please check the output below to verify your drivers are installed" -ForegroundColor Green
    pnputil.exe -e
}
