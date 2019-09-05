$OS = Get-WmiObject Win32_OperatingSystem
if ($OS.Caption.StartsWith("Microsoft Windows Server 2012 R2")) {
    $Posh51Path = "C:\Win8.1AndW2K12R2-KB3191564-x64.msu"
    $Posh51Url = "http://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win8.1AndW2K12R2-KB3191564-x64.msu"
    (New-Object System.Net.Webclient).DownloadFile($Posh51Url,$Posh51Path)
    Start-Process -FilePath "C:\Windows\System32\wusa.exe" -ArgumentList "$Posh51Path /quiet /norestart" -Wait
    Remove-Item $Posh51Path -Force -ErrorAction SilentlyContinue
    $P51Result.Reboot = $true
}elseif($OS.Caption.StartsWith("Microsoft Windows Server 2008 R2")){
    $Posh51Path = "C:\Win7AndW2K8R2-KB3191566-x64.zip"
    $Posh51Url = "http://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win7AndW2K8R2-KB3191566-x64.zip"
    (New-Object System.Net.Webclient).DownloadFile($Posh51Url,$Posh51Path)
    [System.IO.Compression.ZipFile]::ExtractToDirectory($Posh51Path,"C:\PowerShell51\")

    C:\PowerShell51\Install-WMF5.1.ps1 -AcceptEULA
    $Reboot = $false
    do {
        $Reg = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\"
        for ($i = 0; $i -lt $Reg.Count; $i++) {
            if($Reg[$i].ToString().Contains("RebootRequired")){
                $Reboot = $true
                break
            }else{
                $Reboot = $false
            }
        }
        if ($Reboot -eq $true) {
            break
        }else{
            Start-Sleep -Seconds 10
        }
    } until ($Reboot -eq $true)
}
Remove-Item -Path $Posh51Path -Recurse -Force