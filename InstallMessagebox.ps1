param(
    [string]$AppName = "MyMessageBox",
    [string]$Source = ".\Messagebox",
    [string]$InstallLocation = "D:\MessageboxInstallation",
    [string]$DisplayIcon = "D:\MessageboxInstallation\MyIco.ico",
    [string]$Publisher = "JF",
    [string]$UninstallPath = "D:\Windows\${AppName}",
    [string]$UninstallScript = "UninstallMessagebox.ps1",
    [string]$WindowsRegistryString = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"
)

Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

#------------------------------------------------
# App Installation steps
#------------------------------------------------

# Remove installation folder if exist
if(Test-Path($InstallLocation)){
    Remove-Item $InstallLocation -Recurse -Force
}

# Move application binaries
Copy-Item $Source $InstallLocation -Recurse -Force

#Remove uninstallation components if exist
if(Test-Path($UninstallPath)){
    Remove-Item $UninstallPath -Recurse -Force
}

# Move uninstallation components
New-Item -Path $UninstallPath -Type Directory
Copy-Item ".\${UninstallScript}" "${UninstallPath}\" -Recurse -Force

#------------------------------------------------
# Windows registry steps
#------------------------------------------------
$AppRegistryPath = $WindowsRegistryString + "\" + $AppName

$RegPath = Get-Item -Path $AppRegistryPath -ErrorAction "SilentlyContinue"

# Remove windows registry if exist
If($RegPath -ne $NULL){
    Remove-Item -Path $AppRegistryPath -Recurse -Force 
}

# Create windows registry and setup properties
New-Item -Path $WindowsRegistryString -Name $AppName -Value $MyMessageBox -Force
New-ItemProperty -Path $AppRegistryPath -Name "DisplayIcon" -Value $DisplayIcon
New-ItemProperty -Path $AppRegistryPath -Name "DisplayName" -Value $AppName
New-ItemProperty -Path $AppRegistryPath -Name "InstallLocation" -Value $InstallLocation
New-ItemProperty -Path $AppRegistryPath -Name "Publisher" -Value $Publisher

New-ItemProperty -Path $AppRegistryPath -Name "NoModify" -Value "1" -PropertyType DWord
New-ItemProperty -Path $AppRegistryPath -Name "NoRepair" -Value "1" -PropertyType DWord

$UninstallString = @"
powershell.exe -File "${UninstallPath}\${UninstallScript}"
"@

New-ItemProperty -Path $AppRegistryPath -Name "UninstallString" -Value $UninstallString

Pop-Location