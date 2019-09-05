param(
    [ValidateSet("Enabled","Disabled","Clear")]
    [string]$Net452,
    [ValidateSet("Enabled","Disabled","Clear")]
    [string]$Net461,
    [ValidateSet("Enabled","Disabled","Clear")]
    [string]$Net462,
    [ValidateSet("Enabled","Disabled","Clear")]
    [string]$Net47,
    [ValidateSet("Enabled","Disabled","Clear")]
    [string]$Net471,
    [ValidateSet("Enabled","Disabled","Clear")]
    [string]$Net472
)

function SetValue ([string]$ValueName,[int]$ValueData) {
    $WURoot = "HKLM:\Software\Microsoft\NET Framework Setup\NDP\WU"
    if ((Test-Path $WURoot) -eq $false){
        New-Item $WURoot | Out-Null
    }

    $WUChild = Get-ItemProperty $WURoot
    if ($ValueData -eq -1){
        Remove-ItemProperty $WURoot -Name $ValueName -Force -ErrorAction SilentlyContinue | Out-Null
    }else{
        if ($WUChild.$ValueName -eq $null){
            New-ItemProperty $WURoot -Name $ValueName -Value $ValueData | Out-Null
        }else{
            Set-ItemProperty $WURoot -Name $ValueName -Value $ValueData | Out-Null
        }
    }
}

if ($Net452 -eq "Enabled"){
    SetValue -ValueName "BlockNetFramework452" -ValueData 0
}elseif ($Net452 -eq "Disabled"){
    SetValue -ValueName "BlockNetFramework452" -ValueData 1
}elseif ($Net452 -eq "Clear"){
    SetValue -ValueName "BlockNetFramework452" -ValueData -1
}

if ($Net461 -eq "Enabled"){
    SetValue -ValueName "BlockNetFramework461" -ValueData 0
}elseif ($Net461 -eq "Disabled"){
    SetValue -ValueName "BlockNetFramework461" -ValueData 1
}elseif ($Net461 -eq "Clear"){
    SetValue -ValueName "BlockNetFramework461" -ValueData -1
}

if ($Net462 -eq "Enabled"){
    SetValue -ValueName "BlockNetFramework462" -ValueData 0
}elseif ($Net462 -eq "Disabled"){
    SetValue -ValueName "BlockNetFramework462" -ValueData 1
}elseif ($Net462 -eq "Clear"){
    SetValue -ValueName "BlockNetFramework462" -ValueData -1
}

if ($Net47 -eq "Enabled"){
    SetValue -ValueName "BlockNetFramework47" -ValueData 0
}elseif ($Net47 -eq "Disabled"){
    SetValue -ValueName "BlockNetFramework47" -ValueData 1
}elseif ($Net47 -eq "Clear"){
    SetValue -ValueName "BlockNetFramework47" -ValueData -1
}

if ($Net471 -eq "Enabled"){
    SetValue -ValueName "BlockNetFramework471" -ValueData 0
}elseif ($Net471 -eq "Disabled"){
    SetValue -ValueName "BlockNetFramework471" -ValueData 1
}elseif ($Net471 -eq "Clear"){
    SetValue -ValueName "BlockNetFramework471" -ValueData -1
}

if ($Net472 -eq "Enabled"){
    SetValue -ValueName "BlockNetFramework472" -ValueData 0
}elseif ($Net472 -eq "Disabled"){
    SetValue -ValueName "BlockNetFramework472" -ValueData 1
}elseif ($Net472 -eq "Clear"){
    SetValue -ValueName "BlockNetFramework472" -ValueData -1
}