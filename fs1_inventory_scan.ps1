# FS-CERT-FS1-Inventory v1.0
# Truth Protocol v4.3.2 | Codex Certified v5.2.2
# Inventory Scanner with SHA256 + Manifest Logging

param(
    [string]$RootPath = "C:\Users\shane\My Drive\LocalClone\GitHub\Vera\Master"
)

$LogsPath = Join-Path $RootPath "_Logs"
if (!(Test-Path $LogsPath)) {
    New-Item -ItemType Directory -Path $LogsPath | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$progressFile = Join-Path $LogsPath "fs1_inventory_progress_$timestamp.txt"
$jsonIndex = Join-Path $LogsPath "fs1_inventory_index_$timestamp.json"
$csvManifest = Join-Path $LogsPath "fs1_inventory_manifest_$timestamp.csv"
$hashFile = Join-Path $LogsPath "fs1_inventory_hash_$timestamp.txt"

$files = Get-ChildItem -Path $RootPath -Recurse -File -Force -ErrorAction SilentlyContinue
$total = $files.Count
$i = 0
$jsonArray = @()
$csvData = @()

foreach ($file in $files) {
    try {
        $i++
        $relativePath = $file.FullName.Substring($RootPath.Length).TrimStart('\','/')
        $hash = Get-FileHash $file.FullName -Algorithm SHA256 | Select-Object -ExpandProperty Hash
        $item = [PSCustomObject]@{
            Path = $relativePath
            FullPath = $file.FullName
            Size = $file.Length
            LastWrite = $file.LastWriteTimeUtc
            SHA256 = $hash
        }
        $jsonArray += $item
        $csvData += $item
        "$hash *$relativePath" | Out-File -FilePath $hashFile -Append -Encoding utf8

        if ($i % 100 -eq 0) {
            $msg = "[Progress] Processed $i of $total files at $(Get-Date -Format 'HH:mm:ss')"
            Write-Host $msg
            $msg | Out-File -FilePath $progressFile -Append -Encoding utf8
        }
    } catch {
        Write-Warning "[FAILED] $($_.Exception.Message) on file: $($file.FullName)"
    }
}

$jsonArray | ConvertTo-Json -Depth 3 | Out-File -FilePath $jsonIndex -Encoding utf8
$csvData | Export-Csv -Path $csvManifest -NoTypeInformation -Encoding utf8

$msg = "[FS-1] ✅ Completed inventory of $total files at $(Get-Date -Format 'HH:mm:ss')"
Write-Host $msg
$msg | Out-File -FilePath $progressFile -Append -Encoding utf8
