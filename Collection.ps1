$ScriptPath = $MyInvocation.MyCommand.Path
$UsbPath = Split-Path -Parent $ScriptPath
if ([string]::IsNullOrEmpty($UsbPath)) { $UsbPath = ".\" }
$CsvLogPath  = "$UsbPath\Host_Inventory.csv"

$TeamsWebhookURL = "FILL IN YOUR OWN WEBHOOK KEY"

$ComputerName = $env:COMPUTERNAME
$Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$OSCaption    = (Get-WmiObject Win32_OperatingSystem -ErrorAction SilentlyContinue).Caption
$SerialNo     = (Get-WmiObject Win32_BIOS -ErrorAction SilentlyContinue).SerialNumber
$Model        = (Get-WmiObject Win32_ComputerSystem -ErrorAction SilentlyContinue).Model

$UserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

$NetworkAdapter = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | Select-Object -First 1

$IPAddress = if ($NetworkAdapter.IPAddress) { [string]($NetworkAdapter.IPAddress[0]) } else { "No Active Connection" }
$MACAddress = if ($NetworkAdapter.MACAddress) { [string]$NetworkAdapter.MACAddress } else { "N/A" }

$CsvEntry = [PSCustomObject]@{
    Timestamp    = $Timestamp
    ComputerName = $ComputerName
    CurrentUser  = $UserName
    IPAddress    = $IPAddress
    MACAddress   = $MACAddress
    OSVersion    = $OSCaption
    SerialNumber = $SerialNo
    Model        = $Model
}
$CsvEntry | Export-Csv -Path $CsvLogPath -Append -NoTypeInformation -Encoding utf8

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Payload = @{
    type = "message"
    attachments = @(
        @{
            contentType = "application/vnd.microsoft.card.adaptive"
            content = @{
                type = "AdaptiveCard"
                version = "1.4"
                body = @(
                    @{
                        type = "TextBlock"
                        text = "System Inventory Discovered"
                        weight = "Bolder"
                        size = "Large"
                        color = "Accent"
                    },
                    @{
                        type = "TextBlock"
                        text = "User and Session Profile"
                        weight = "Bolder"
                        size = "Small"
                        separator = $true
                    },
                    @{
                        type = "FactSet"
                        facts = @(
                            @{ title = "Computer Name:"; value = "$ComputerName" }
                            @{ title = "Logged-In User:"; value = "$UserName" }
                            @{ title = "Timestamp:"; value = "$Timestamp" }
                        )
                    },
                    @{
                        type = "TextBlock"
                        text = "Hardware and OS Specifications"
                        weight = "Bolder"
                        size = "Small"
                        separator = $true
                    },
                    @{
                        type = "FactSet"
                        facts = @(
                            @{ title = "Operating System:"; value = "$OSCaption" }
                            @{ title = "Serial Number:"; value = "$SerialNo" }
                            @{ title = "Device Model:"; value = "$Model" }
                        )
                    },
                    @{
                        type = "TextBlock"
                        text = "Network Parameters"
                        weight = "Bolder"
                        size = "Small"
                        separator = $true
                    },
                    @{
                        type = "FactSet"
                        facts = @(
                            @{ title = "Active IPv4:"; value = "$IPAddress" }
                            @{ title = "MAC Address:"; value = "$MACAddress" }
                        )
                    }
                )
                "`$schema" = "http://adaptivecards.io"
            }
        }
    )
} | ConvertTo-Json -Depth 10

$Utf8Payload = [System.Text.Encoding]::UTF8.GetBytes($Payload)

try {
    $Response = Invoke-RestMethod -Uri $TeamsWebhookURL -Method Post -Body $Utf8Payload -ContentType "application/json; charset=utf-8"
    Write-Host "[+] Enhanced data sent to Teams successfully!" -ForegroundColor Green
} catch {
    Write-Host "[-] Failed to send to Teams. Error: $_" -ForegroundColor Red
}