param(
    [Parameter(Mandatory=$true)]
    [string]$VMName,
    [Parameter(Mandatory=$true)]
    [string]$MacAddress,
    [Parameter(Mandatory=$true)]
    [int]$RAM,
    [Parameter(Mandatory=$true)]
    [int]$HDSizeGB,
    [Parameter(Mandatory=$false)]
    [int]$SecondHDSizeGB = 0,
    [Parameter(Mandatory=$false)]
    [string]$SwitchName = "HomeLab Switch",
    [Parameter(Mandatory=$false)]
    [int]$ProcessorCount = 5,
    [Parameter(Mandatory=$false)]
    [string]$ISOPath = "D:\iso\ubuntu-24.04.3-live-server-amd64.iso"
)

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Write-Host "[$timestamp] $Message"
}

# Check if VM exists
if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) {
    Write-Log "VM '$VMName' already exists. Skipping creation."
    return
}

Write-Log "Creating VHDX for $VMName..."
$VHDPath = "D:\VirtualMachines\Virtual Hard Disks\$VMName.vhdx"
New-VHD -Path $VHDPath -SizeBytes ($HDSizeGB * 1GB) -Dynamic | Out-Null

if ($SecondHDSizeGB -gt 0) {
    Write-Log "Creating second VHDX for $VMName..."
    $SecondVHDPath = "D:\VirtualMachines\Virtual Hard Disks\$VMName-2.vhdx"
    New-VHD -Path $SecondVHDPath -SizeBytes ($SecondHDSizeGB * 1GB) -Dynamic | Out-Null
}

Write-Log "Creating VM $VMName..."
New-VM -Name $VMName -MemoryStartupBytes ($RAM * 1MB) -Generation 2 -VHDPath $VHDPath -SwitchName $SwitchName | Out-Null

Write-Log "Disabling dynamic memory..."
Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $false

Write-Log "Setting processor count to $ProcessorCount..."
Set-VMProcessor -VMName $VMName -Count $ProcessorCount

Write-Log "Setting static MAC address..."
Set-VMNetworkAdapter -VMName $VMName -StaticMacAddress $MacAddress

if ($SecondHDSizeGB -gt 0) {
    Write-Log "Attaching second VHDX to $VMName..."
    Add-VMHardDiskDrive -VMName $VMName -Path $SecondVHDPath
}

Write-Log "Adding DVD drive and attaching ISO..."
Add-VMDvdDrive -VMName $VMName -Path $ISOPath

Write-Log "Enabling Secure Boot..."
Set-VMFirmware -VMName $VMName -EnableSecureBoot On -SecureBootTemplate "MicrosoftUEFICertificateAuthority"

Write-Log "VM $VMName creation complete."
