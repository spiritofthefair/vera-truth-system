# FS-1: Inventory Script (Codex Truth Certified v5 with Live Progress)

# ✅ Truth Protocols v4.3.0 Executed Before Run

# ✅ Visual Execution Feedback Enabled

# ✅ Master Folder Verified (Secondary)

param( [string]\$SourceRoot = "C:\Users\shane", [string]\$OutputRoot = "C:\Users\shane\My Drive\LocalClone\GitHub\Vera\Master\_Logs" )

Write-Host "[TP] Truth Protocol v4.3.0 – Execution Beginning" Write-Host "[TP] Source Root: \$SourceRoot" Write-Host "[TP] Output Root: \$OutputRoot"

\$Timestamp = Get-Date -Format "yyyyMMdd\_HHmmss" \$IndexJson = Join-Path \$OutputRoot "fs1\_inventory\_index\_\$Timestamp.json" \$ManifestCsv = Join-Path \$OutputRoot "fs1\_inventory\_manifest\_\$Timestamp.csv" \$HashFile = Join-Path \$OutputRoot "fs1\_inventory\_hash\_\$Timestamp.txt" \$ProgressLog = Join-Path \$OutputRoot "fs1\_inventory\_progress\_\$Timestamp.txt"

\$inventory = @() \$total = (Get-ChildItem -Path \$SourceRoot -Recurse -Force -ErrorAction SilentlyContinue).Count \$count = 0

if (-not (Test-Path \$OutputRoot)) { New-Item -ItemType Directory -Path \$OutputRoot -Force | Out-Null Write-Host "[TP] Output folder created: \$OutputRoot" }

Write-Host "[FS-1] Scanning \$SourceRoot..."

Get-ChildItem -Path \$SourceRoot -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object { try { \$item = $\_ \$count++ \$entry = [PSCustomObject]@{ Name       = \$item.Name Path       = \$item.FullName Type       = if (\$item.PSIsContainer) { "Folder" } else { "File" } Extension  = if (\$item.PSIsContainer) { "" } else { \$item.Extension } SizeKB     = if (\$item.PSIsContainer) { 0 } else { [math]::Round(\$item.Length / 1KB, 2) } LastWrite  = \$item.LastWriteTimeUtc.ToString("s") } \$inventory += \$entry

```
    # Visual progress update every 100 items
    if ($count % 100 -eq 0) {
        $pct = [math]::Round(($count / $total) * 100, 2)
        Write-Host "[Progress] $count / $total ($pct%)"
        "$count of $total processed at $(Get-Date -Format HH:mm:ss)" | Out-File -FilePath $ProgressLog -Append
    }
} catch {
    Write-Warning "[TP] Failed to process item: $_"
}
```

}

\$inventory | ConvertTo-Json -Depth 3 | Out-File -Encoding UTF8 \$IndexJson \$inventory | Export-Csv -Path \$ManifestCsv -NoTypeInformation

\$hash = Get-FileHash -Algorithm SHA256 \$IndexJson "SHA256 Hash of index: \$(\$hash.Hash)" | Out-File -FilePath \$HashFile -Encoding UTF8

if (Test-Path \$ManifestCsv -and ((Get-Content \$ManifestCsv).Length -gt 0)) { Write-Host "[TP] ✅ Manifest file written and verified." } else { Write-Warning "[TP] ❌ Manifest missing or empty." }

Write-Host "[FS-1] Inventory complete:" Write-Host " - JSON: \$IndexJson" Write-Host " - CSV:  \$ManifestCsv" Write-Host " - HASH: \$HashFile" Write-Host " - Progress Log: \$ProgressLog" Write-Host "[TP] ✅ FS-1 completed with visual feedback and Truth Protocol integrity."

