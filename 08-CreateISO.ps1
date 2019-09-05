param(
    # The path to the extracted Installation ISO
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]$ExtractedISOPath,

    # The destination path and file name to save the new ISO
    [Parameter(Mandatory=$true)]
    [ValidateScript({
        if (Test-Path $_) {
            Write-Error "The specified DestinationFile already exists, please figure that whole thing out and try again!"
            $false
        } else {
            $true
        }
    })]
    [string]$DestinationFile,

    # The updated .wim file to replace
    [Parameter(Mandatory=$false)]
    [ValidateScript({
        if (Test-Path $_) {
            $true
        } else {
            Write-Error "The updated .wim file you've specified doesn't appear to exist for some reason..."
            $false
        }
    })]
    [string]$UpdatedWimFile=$null,

    # Parameter help description
    [Parameter(Mandatory=$false)]
    [switch]$SkipBootDriverUpdate,

    # The OS version for proper driver injection
    [Parameter(Mandatory=$true)]
    [ValidateSet("2008R2","2016")]
    [string]$OperatingSystem
)

if ($SkipBootDriverUpdate) {
    Write-Host "Skipping the addition of the boot boot drivers into the PE and Install environments" -ForegroundColor Yellow
} else {
    $BootPath = Join-Path $ExtractedISOPath "sources\boot.wim"
    Get-WindowsImage -ImagePath $BootPath | % {
        Write-Host "Processing Image Index $($_.ImageIndex), Name: $($_.ImageName)" -ForegroundColor Yellow
        $MountPath = Join-Path $ExtractedISOPath "\Mount\"
        mkdir $MountPath | Out-Null
        Mount-WindowsImage -Path $MountPath -ImagePath $BootPath -Index $_.ImageIndex -CheckIntegrity
        if ($OperatingSystem -eq "2008R2") {
            Write-Host "Installing boot drivers for Server 2008R2" -ForegroundColor Yellow
            Add-WindowsDriver -Path $MountPath -Driver ".\HPE-Gen10Array-11-27-2018\SmartPqi.inf"
            Add-WindowsDriver -Path $MountPath -Driver ".\VMware-Tools-core-10.3.5-10430147\Drivers\pvscsi\Vista\amd64\pvscsi.inf"
        } elseif ($OperatingSystem -eq "2016") {
            Write-Host "Installing boot drivers for Server 2016" -ForegroundColor Yellow
            Add-WindowsDriver -Path $MountPath -Driver ".\HPE-Gen10Array-11-27-2018\SmartPqi.inf"
            Add-WindowsDriver -Path $MountPath -Driver ".\VMware-Tools-core-10.3.5-10430147\Drivers\pvscsi\Win8\amd64\pvscsi.inf"
        }
        Write-Host "Commiting changes back to the boot wim" -ForegroundColor Yellow
        Dismount-WindowsImage -Path $MountPath -Save -CheckIntegrity
        Remove-Item $MountPath -Force -Recurse | Out-Null
    }
}

if ($UpdatedWimFile -eq $null) {
    Write-Host "No updated .wim was specified, skipping this step" -ForegroundColor Yellow
} else {
    Write-Host "Adding the specified .wim file to the extracted ISO directory" -ForegroundColor Yellow
    $WimName = (Get-Item $UpdatedWimFile).Name
    if ($WimName -ne "install.wim") {
        $Rename = $true
    }
    $SourcesDir = (Join-Path $ExtractedISOPath "\sources\")
    Copy-Item $UpdatedWimFile $SourcesDir -Force
    if ($Rename) {
        Write-Host "Renaming the copied wim to install.wim" -ForegroundColor Yellow
        Remove-Item -Path (Join-Path $SourcesDir "install.wim") -Force
        Rename-Item -Path (Join-Path $SourcesDir $WimName) -NewName "install.wim" -Force
    }
}
Write-Host "Creating ISO" -ForegroundColor Yellow
$ETFSBootPath = Join-Path $ExtractedISOPath "boot\etfsboot.com"
.\Oscdimg\oscdimg.exe -b"$ETFSBootPath" -u2 -h -m -lWIN_EN_DVD "$ExtractedISOPath" $DestinationFile