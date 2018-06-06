
# Initialize MSI Afterburner interface
$baseFolder = Split-Path -parent $script:MyInvocation.MyCommand.Path

try {
    Add-Type -Path $baseFolder\MSIAfterburner.NET.dll
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    throw "Failed to load Afterburner interface library"
}

try {
    $abMonitor = New-Object MSI.Afterburner.HardwareMonitor
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    Write-Log "Failed to create MSI Afterburner Monitor object. Falling back to standard monitoring" $LogFile $true
    $abMonitor = $false
    Start-Sleep -Seconds 5
}

try {
    $abControl = New-Object MSI.Afterburner.ControlMemory
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    Write-Log "Failed to create MSI Afterburner Control object. PowerLimits will not be available" $LogFile $true
    $abControl = $false
    Start-Sleep -Seconds 5
}

function Set-AfterburnerPowerLimit ([int]$PowerLimitPercent, [string]$DeviceGroupType, [string]$Devices) {

    try {
        $abMonitor.ReloadAll()
        $abControl.ReloadAll()
    } catch {
        Write-Host $_.Exception.Message -ForegroundColor Yellow
        throw "Failed to communicate with MSI Afterburner"
    }

    $DevicesArray=$Devices -split ','
    if ($DevicesArray.Length -gt 0) {

        if ($DeviceGroupType -eq "AMD") {
            $PowerLimit = $PowerLimitPercent - 100
        } else {
            $PowerLimit = $PowerLimitPercent
        }

        $Pattern = @{
            AMD    = '*Radeon*'
            NVIDIA = '*GeForce*'
            Intel  = '*Intel*'
        }

        $Devices = @($abMonitor.GpuEntries | Where-Object Device -like $Pattern.$($DeviceGroupType) | Select-Object -ExpandProperty Index)[$DevicesArray]

        foreach ($device in $Devices) {
            if ($abControl.GpuEntries[$device].PowerLimitCur -ne $PowerLimit) {

                # Stay within HW limitations
                if ($PowerLimit -gt $abControl.GpuEntries[$device].PowerLimitMax) {$PowerLimit = $abControl.GpuEntries[$device].PowerLimitMax}
                if ($PowerLimit -lt $abControl.GpuEntries[$device].PowerLimitMin) {$PowerLimit = $abControl.GpuEntries[$device].PowerLimitMin}

                $abControl.GpuEntries[$device].PowerLimitCur = $PowerLimit
            }
        }
        $abControl.CommitChanges()
    }
}

function Get-AfterburnerDevices ($Type) {
    try {
        $abControl.ReloadAll()
    } catch {
        Write-Host $_.Exception.Message -ForegroundColor Yellow
        throw "Failed to communicate with MSI Afterburner"
    }

    if ($Type -in @('AMD', 'NVIDIA', 'Intel')) {
        $Pattern = @{
            AMD    = "*Radeon*"
            NVIDIA = "*GeForce*"
            Intel  = "*Intel*"
        }
        @($abMonitor.GpuEntries) | Where-Object Device -like $Pattern.$Type | ForEach-Object {
            $abIndex = $_.Index
            $abMonitor.Entries | Where-Object {
                $_.GPU -eq $abIndex -and
                $_.SrcName -match "(GPU\d+ )?" -and
                $_.SrcName -notmatch "CPU"
            } | Format-Table
            @($abControl.GpuEntries)[$abIndex]
        }
    } elseif ($Type -eq 'CPU') {
        $abMonitor.Entries | Where-Object {
            $_.GPU -eq [uint32]"0xffffffff" -and
            $_.SrcName -match "CPU"
        } | Format-Table
    }
}