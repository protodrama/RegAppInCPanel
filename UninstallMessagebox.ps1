param(
    [string]$AppName = "MyMessageBox",
    [string]$RegistryString = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
)

# Check registry existance
$AppRegistryPath = "${RegistryString}\${AppName}"

$RegPath = Get-Item -Path $AppRegistryPath -ErrorAction "SilentlyContinue"

If($RegPath -ne $NULL){

    # Get and remove installation folder
    $InstallLocation = Get-ItemProperty -Path $AppRegistryPath | Select -ExpandProperty InstallLocation

    if(Test-Path($InstallLocation)){
        Remove-Item $InstallLocation -Recurse -Force
    }

    # Remove windows registry
    Remove-Item -Path $AppRegistryPath -Recurse -Force
}
else
{
    $Message = "The application '" + $AppName + "' is not found in the registry."
    Write-Error $Message
    exit -1
}
