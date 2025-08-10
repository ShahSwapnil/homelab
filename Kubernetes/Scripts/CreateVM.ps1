<#
.SYNOPSIS
    Creates a Hyper-V Virtual Machine on Windows 11 with specific static configurations.

.DESCRIPTION
    This script automates the creation of a Hyper-V VM with the following
    strict requirements:
    - Generation 2 VM
    - Static (non-dynamic) memory
    - Specific virtual processor count
    - Connection to a pre-defined, existing virtual network switch (no fallback to internal)
    - Configurable static MAC address
    - Secure Boot enabled with 'MicrosoftUEFICertificateAuthority' template
    - Automatic checkpoints disabled (enabling manual checkpoints only)
    - Starts the VM after creation for OS installation from an ISO.

.PARAMETER VMName
    The name for the new Virtual Machine. Must be unique.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, HelpMessage="Name for the new Virtual Machine.")]
    [string]$VMName,

    [Parameter(Mandatory=$true, HelpMessage="Static MAC address for the VM's network adapter (e.g., '00155D010203').")]
    [string]$MacAddress,

    [Parameter(Mandatory=$false, HelpMessage="Exact amount of RAM to allocate (e.g., '4GB', '8192MB').")]
    [System.Int64]$MemoryStartupBytes = '32GB',

    [Parameter(Mandatory=$false, HelpMessage="Maximum size of the Virtual Hard Disk file in Gigabytes.")]
    [int]$VHDSizeGB = 50,

    [Parameter(Mandatory=$false)]
    [string]$SwitchName = "HomeLab Switch",

    [Parameter(Mandatory=$false)]
    [int]$ProcessorCount = 4,

    [Parameter(Mandatory=$false)]
    [string]$ISOPath = "D:\iso\ubuntu-24.04.2-live-server-amd64.iso"
)

$baseVHDPath = "D:\VirtualMachines\Virtual Hard Disks"

# --- Function for consistent logging ---
function Write-ScriptMessage {
    param(
        [string]$Message,
        [string]$Level = "Info" # Info, Success, Warning, Error
    )
    switch ($Level) {
        "Info"    { Write-Host "INFO: $Message" -ForegroundColor Cyan }
        "Success" { Write-Host "SUCCESS: $Message" -ForegroundColor Green }
        "Warning" { Write-Warning "$Message" }
        "Error"   { Write-Error "$Message" -ErrorAction Stop } # Stop script on critical errors
        default   { Write-Host "$Message" }
    }
}

Write-ScriptMessage -Message "--- Starting Hyper-V VM Creation Script ---"

$VHDPath = Join-Path -Path $baseVHDPath -ChildPath "$VMName.VHDX"

Write-ScriptMessage -Message "VHD Path: $VHDPath"

if ( Test-path $VHDPath ) {
	Write-ScriptMessage -Message "Virtual Hard Disk already exists" -Level Error
	return
}

# --- 3. Create the Virtual Machine ---
Write-ScriptMessage -Message "Creating new VM '$VMName'..."

try {
    New-VM -Name $VMName `
                    -MemoryStartupBytes $MemoryStartupBytes `
                    -NewVHDPath $VHDPath `
                    -NewVHDSizeBytes ($VHDSizeGB * 1GB) `
                    -Generation 2 `
                    -SwitchName $SwitchName `

    Write-ScriptMessage -Message "VM '$VMName' created successfully." -Level Success
}
catch {
    Write-ScriptMessage -Message "Failed to create VM '$VMName': $($_.Exception.Message)" -Level Error
	return
}

# Add the DVD Drive
try {
    $dvdDrive = Add-VMDvdDrive -VMName $VMName -Path $ISOPath -Passthru
    Write-ScriptMessage -Message "Virtual DVD Drive added successfully for '$VMName'." -Level Success
}
catch {
    Write-ScriptMessage -Message "Failed to add DVD drive to VM '$VMName': $($_.Exception.Message)" -Level Error
    # You might want to remove the VM here if adding the DVD drive is critical
    Remove-VM -Name $VMName -Force -Confirm:$false
    return
}

Write-ScriptMessage -Message "Configure VM with the following Options"
Write-ScriptMessage -Message "- Shutdown when Hyper-V host is shut down"
Write-ScriptMessage -Message "- Start VM whenever the Host starts up"
Write-ScriptMessage -Message "- Don't use Dynamic Memory"
Write-ScriptMessage -Message "- Processor Count to $ProcessorCount"

Set-VM -Name $VMName -AutomaticStopAction ShutDown `
					 -AutomaticStartAction Start `
					 -CheckpointType Standard `
					 -StaticMemory `
					 -ProcessorCount $ProcessorCount `

# Write-ScriptMessage -Message "Configure Virtual DVD Drive to use to ISO image"
# Set-VMDvdDrive -VMName $VMName -Path ISOPath

Write-ScriptMessage -Message "Configure MAC Address"
Set-VMNetworkAdapter -VMName $VMName -StaticMacAddress $MacAddress

Write-ScriptMessage -Message "Configure Secure Boot Template"
Set-VMFirmware -VMName $VMName -SecureBootTemplate "MicrosoftUEFICertificateAuthority"
Write-ScriptMessage -Message "--- Script Finished ---"

Write-ScriptMessage -Message "--- Starting VM ---"
Start-VM -Name $VMName
Write-ScriptMessage -Message "VM '$VMName' creation and initial setup complete." -Level Success
Write-ScriptMessage -Message "You can now connect to the VM via Hyper-V Manager to begin the OS installation." -Level Info
Write-ScriptMessage -Message "--- VM Started ---"
