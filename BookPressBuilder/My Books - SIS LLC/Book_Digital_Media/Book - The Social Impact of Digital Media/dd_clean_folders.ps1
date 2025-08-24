# FS-CERT-BOOKOPS-01
# Truth Protocol v4.3.1 Certified | Codex Certified v5.1.1
# CLEAN + CONSOLIDATE: B04_Digital_Dilemma Book Folder

$Root = "J:\\Shared drives\\Automation Drive\\2IOS\\Business\\Social Impact Solutions LLC (SIS LLC)\\SIS LLC (My Books)\\B04_Digital_Dilemma"

$Map = @{
    "manuscript" = "Manuscript"
    "workbook"   = "Workbook"
    "image"      = "Images"
    "img"        = "Images"
    "cover"      = "Images"
    "draft"      = "Drafts"
    "note"       = "References"
    "backup"     = "Unused_Archived"
    "copy"       = "Unused_Archived"
}

$NewStructure = @("Manuscript", "Workbook", "Images", "References", "Drafts", "Unused_Archived", "Final", "Manifest")
$LogPath = Join-Path $Root ("Manifest\\dd_clean_log_" + (Get-Date -Format 'yyyyMMdd_HHmmss') + ".txt")

# Create Folders
foreach ($f in $NewStructure) {
    $fp = Join-Path $Root $f
    if (!(Test-Path $fp)) {
        New-Item -ItemType Directory -Path $fp | Out-Null
        Add-Content $LogPath ("[Created Folder] " + $fp)
    }
}

# Move Files into Correct Location
Get-ChildItem -Path $Root -Recurse -File | ForEach-Object {
    try {
        $target = $_.FullName
        $destKey = $Map.Keys | Where-Object { $target -match $_ }
        $dest = if ($destKey) { Join-Path $Root $Map[$destKey[0]] } else { Join-Path $Root "References" }
        Move-Item -Path $target -Destination $dest -Force -ErrorAction Stop
        Add-Content $LogPath ("[Moved] " + $_.Name + " → " + $dest)
    } catch {
        Add-Content $LogPath ("[FAILED] " + $_.Name + " → " + $dest + " | " + $_.Exception.Message)
    }
}

Write-Host ("`n[TP] B04 Folder Clean Complete. Log located at: " + $LogPath + "`n")
