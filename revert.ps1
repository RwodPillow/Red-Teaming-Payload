# 1. Define Scope
$TargetDir = "$env:USERPROFILE\OneDrive\Desktop"
$Extension = ".locked-corp"
$RansomNotePath = "$TargetDir\RECOVERY_INSTRUCTIONS.txt"

# 2. Find All Encrypted Drill Files
$EncryptedFiles = Get-ChildItem -Path $TargetDir -Filter "*$Extension" -Recurse -ErrorAction SilentlyContinue

# 3. Decode Files Back to Original State
foreach ($File in $EncryptedFiles) {
    try {
        # Read Base64 string
        $Base64 = [System.IO.File]::ReadAllText($File.FullName)
        $Bytes = [System.Convert]::FromBase64String($Base64)
        
        # Determine original file path by stripping the drill extension
        $OriginalPath = $File.FullName.Substring(0, $File.FullName.Length - $Extension.Length)
        
        # Restore original file bytes
        [System.IO.File]::WriteAllBytes($OriginalPath, $Bytes)
        
        # Remove the drill file
        Remove-Item $File.FullName -Force
    } catch {
        Write-Warning "Could not restore: $($File.Name)"
    }
}

# 4. Clean Up Ransom Note
if (Test-Path $RansomNotePath) {
    Remove-Item $RansomNotePath -Force
}

Write-Host "Rollback complete! All files have been safely restored." -ForegroundColor Green
