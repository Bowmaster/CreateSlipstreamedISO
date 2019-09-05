<# 
Builds a WIM
.\05-BuildWIM.ps1 -VHDPath D:\Virtualbox\Server2016-Core\Server2016-Core.vhd `
    -MountPath D:\Virtualbox\Mount\Server2016Core\ `
    -ImageName "Windows Server 2016 Standard (Core)" `
    -ImageDescription "Windows Server 2016 Standard (Core)" `
    -DestinationFile D:\Virtualbox\Server2016Core.wim `
    -ScratchDirectory D:\Virtualbox\Scratch\

Appends a WIM into an Existing WIM
.\05-BuildWIM.ps1 -VHDPath D:\Virtualbox\Server2016-GUI\Server2016-GUI.vhd `
    -MountPath D:\Virtualbox\Mount\Server2016GUI\ `
    -ImageName "Windows Server 2016 Standard (GUI)" `
    -ImageDescription "Windows Server 2016 Standard (GUI)" `
    -AppendMode `
    -SkipExport `
    -TargetWim D:\Virtualbox\Server2016Core.wim `
    -ScratchDirectory D:\Virtualbox\Scratch\
#>
param(
    # The path to the Virtual HardDisk to Mount
    [Parameter(ParameterSetName="Append", Mandatory=$true)]
    [Parameter(ParameterSetName="Normal", Mandatory=$true)]
    [ValidateScript({Test-Path $_})]
    [string]$VHDPath,

    # The location to mount the VHD
    [Parameter(ParameterSetName="Append", Mandatory=$true)]
    [Parameter(ParameterSetName="Normal",Mandatory=$true)]
    [string]$MountPath,

    # The Name to imprint on the .wim file, this must be unique from any other .wim you are going to append to this .wim
    [Parameter(ParameterSetName="Append", Mandatory=$true)]
    [Parameter(ParameterSetName="Normal",Mandatory=$true)]
    [string]$ImageName,

    # The Description to imprint on the .wim file, this must be unique from any other .wim you are going to append to this .wim
    [Parameter(ParameterSetName="Append", Mandatory=$true)]
    [Parameter(ParameterSetName="Normal",Mandatory=$true)]
    [string]$ImageDescription,

    # The destination location for the .wim file
    [Parameter(ParameterSetName="Append", Mandatory=$false)]
    [Parameter(ParameterSetName="Normal",Mandatory=$true)]
    [string]$DestinationFile=$null,

    # The destination to put scratch files
    [Parameter(ParameterSetName="Append", Mandatory=$false)]
    [Parameter(ParameterSetName="Normal",Mandatory=$true)]
    [string]$ScratchDirectory="C:\Windows\Temp\Scratch",

    # States that this .wim will be appended to another .wim
    [Parameter(ParameterSetName="Append")]
    [switch]$AppendMode,

    # Skips the export of the wim and only appends
    [Parameter(ParameterSetName="Append")]
    [switch]$SkipExport,

    # The target .wim to append to
    [Parameter(ParameterSetName="Append",Mandatory=$true)]
    [ValidateScript({Test-Path $_})]
    [string]$TargetWim
)

if ((Test-Path $MountPath) -eq $false) {
    Write-Host "Creating the mount directory" -ForegroundColor Yellow
    mkdir $MountPath -Force
}
if ((Test-Path $ScratchDirectory) -eq $false) {
    Write-Host "Creating the scratch directory and will delete it once finished since it is not an already existing directory" -ForegroundColor Yellow
    mkdir $ScratchDirectory -Force
    $RemoveScratch -eq $true
}
if ($DestinationFile -eq $null) {
    Write-Host "No destination file name was set to setting it to the current directory using the supplied image name value" -ForegroundColor Yellow
    $DestinationFile = ".\$ImageName.wim"
}

Write-Host "Mounting $VHDPath to $MountPath" -ForegroundColor Yellow
Mount-WindowsImage -ImagePath $VHDPath -Path $MountPath -Index 1
Write-Host "Finished mounting VHD"
timeout -1
if ($AppendMode) {
    Write-Host "Appending the mounted volume to $TargetWim" -ForegroundColor Yellow
    Add-WindowsImage -ImagePath $TargetWim -CapturePath $MountPath -Name $ImageName -Description $ImageDescription -CheckIntegrity -Verify
    Write-Host "Finished appending the image" -ForegroundColor Yellow
}
if ($SkipExport -eq $false) {
    Write-Host "Creating a .wim file named $ImageName in $DestinationFile" -ForegroundColor Yellow
    New-WindowsImage -CapturePath $MountPath -ImagePath $DestinationFile -Name $ImageName -Description $ImageDescription -Verify -CheckIntegrity
    Write-Host "Finished creating the new .wim" -ForegroundColor Yellow
} else {
    Write-Host "Skipping .wim creation" -ForegroundColor Yellow
}

Write-Host "Unmounting VHD and discarding changes" -ForegroundColor Yellow
Dismount-WindowsImage -Path $MountPath -Discard

if ($RemoveScratch) {
    Write-Host "Removing default scratch directory."
    Remove-Item $ScratchDirectory -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "All operations completed!" -ForegroundColor Green