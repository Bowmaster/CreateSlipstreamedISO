$OS = Get-WmiObject Win32_OperatingSystem
if ($OS.Caption.StartsWith("Microsoft Windows Server 2016")){

}else{
    $NetFXPath = "C:\NDP452-KB2901907-x86-x64-AllOS-ENU.exe"
    $NetFXUrl = "https://download.microsoft.com/download/E/2/1/E21644B5-2DF2-47C2-91BD-63C560427900/NDP452-KB2901907-x86-x64-AllOS-ENU.exe"

    (New-Object System.Net.Webclient).DownloadFile($NetFXUrl,$NetFXPath)
    Start-Process -FilePath $NetFXPath -ArgumentList "/quiet /norestart" -Wait
    Remove-Item $NetFXPath -Force -ErrorAction SilentlyContinue
}