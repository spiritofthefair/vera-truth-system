# FS2_RELOCATION_MATRIX.ps1
# Codex-Certified v5.1.2 | Truth Protocol v4.3.1 | FS Phase 2
# Author: Shane Russell (System Ops via Vera)

param(
    [string]$FS1JsonPath = "C:\Users\shane\My Drive\LocalClone\GitHub\Vera\Master\_Logs\fs1_inventory_index_latest.json",
    [string]$RootDestination = "C:\Users\shane\My Drive\LocalClone\Master"
)

Write-Host "[TP] FS-2 Initialization under Truth Protocols v4.3.1"

if (!(Test-Path $FS1JsonPath)) {
    Write-Error "[TP] ❌ FS-1 inventory file not found: $FS1JsonPath"
    exit 1
}

$Inventory = Get-Content $FS1JsonPath | ConvertFrom-Json
$RelocationPlan = @()

$Rules = @{
    ".ps1"     = "Scripts"
    ".json"    = "Metadata"
    ".csv"     = "Logs"
    ".txt"     = "Logs"
    ".docx"    = "Books"
    ".pdf"     = "Books"
    ".gdoc"    = "Books"
    ".xlsx"    = "Data"
    ".png"     = "Media"
    ".jpg"     = "Media"
    ".webp"    = "Media"
    ".zip"     = "Archives"
    ".log"     = "Logs"
}

function Resolve-DestinationPath($file) {
    $ext = [IO.Path]::GetExtension($file.Path).ToLower()
    $typeFolder = if ($Rules.ContainsKey($ext)) { $Rules[$ext] } else { "Unsorted" }
    $targetDir = Join-Path $RootDestination $typeFolder
    return Join-Path $targetDir $file.Name
}

foreach ($f in $Inventory) {
    $to = Resolve-DestinationPath $f
    $entry = [PSCustomObject]@{
        Source      = $f.FullPath
        Target      = $to
        Type        = [IO.Path]::GetExtension($f.Path).ToLower()
        Tag         = if ($Rules.ContainsKey($f.Extension)) { $Rules[$f.Extension] } else { "Unsorted" }
    }
    $RelocationPlan += $entry
}

$RelocationPlanPath = Join-Path $RootDestination "_Logs\fs2_relocation_matrix_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
if (!(Test-Path (Split-Path $RelocationPlanPath))) {
    New-Item -ItemType Directory -Force -Path (Split-Path $RelocationPlanPath) | Out-Null
}

$RelocationPlan | ConvertTo-Json -Depth 3 | Out-File -FilePath $RelocationPlanPath -Encoding utf8

Write-Host "[FS-2] ✅ Relocation Matrix Created: $RelocationPlanPath"
