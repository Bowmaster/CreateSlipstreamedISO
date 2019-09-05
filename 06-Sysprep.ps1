$Date = Get-Date -Format yyyy.MM.dd_HH.MM.ss
$Date > C:\Windows\BuildInfo.stamp

if ((Get-WmiObject Win32_OperatingSystem | select Caption) -match 2008){
    $StreamProvider = "HKLM:\SOFTWARE\Microsoft\Windows\StreamProvider"
    $SysPrep = "HKLM:\SYSTEM\Setup\Status\SysprepStatus\GeneralizationState"
    
    if ((Test-Path $StreamProvider) -eq $false) {
        Write-Host "Creating the StreamProvider registry key." -ForegroundColor Yellow
        New-Item $StreamProvider -Force
    }
    
    Set-SilLogging –TargetUri https://BlankTarget –CertificateThumbprint 0123456789
    Publish-SilData -ErrorAction SilentlyContinue
    Remove-Item -Recurse $env:SystemRoot\System32\Logfiles\SIL\ -ErrorAction SilentlyContinue

    $StreamProviderData = Get-ItemProperty $StreamProvider
    if($StreamProviderData.LastFullPayloadTime -eq $null) {
        Write-Host "Creating 'LastFullPayloadTime' with a value of 0." -ForegroundColor Yellow
        New-ItemProperty $StreamProvider -Name "LastFullPayloadTime" -Value 0 -Force
    }else{
        Write-Host "Setting 'LastFullPayloadTime' to a value of 0." -ForegroundColor Yellow
        Set-ItemProperty $StreamProvider -Name "LastFullPayloadTime" -Value 0 -Force
    }

    New-Item $SysPrep -Force -ErrorAction SilentlyContinue
    Set-ItemProperty $SysPrep -Name "CleanupState" -Value "2" -Force
    Set-ItemProperty $SysPrep -Name "GeneralizationState" -Value "7" -Force

    msdtc -uninstall
    Start-Sleep -Seconds 20
    msdtc -install
    Start-Sleep -Seconds 20
    
}
Write-Host "Attempting to sysprep." -ForegroundColor Green
C:\windows\system32\sysprep\sysprep.exe /generalize /oobe /quiet /shutdown