<# 
Build-BookFromChat.ps1  — VARA | BUILDS BY DEFAULT | PowerShell 5.1 compatible
Fixed script location; prompts you for the book folder and chat file if not provided.

Default locations (change with -ProjectRoot / -TemplateRoot):
  ProjectRoot : E:\LocalClone\LocalClone\GitHub\Vera-FIXED-1\BookPressBuilder\My Books - SIS LLC
  TemplateRoot: E:\LocalClone\LocalClone\GitHub\Vera-FIXED-1\BookPressBuilder\templates

Outputs (always overwritten):
  <BookFolder>\Chat_Book_Build\<BookTitle>.md
  <BookFolder>\Chat_Book_Build\manifest.json
  <BookFolder>\Chat_Book_Build\BuildReport.md
#>

[CmdletBinding()]
param(
  [string]$ProjectRoot = "E:\LocalClone\LocalClone\GitHub\Vera-FIXED-1\BookPressBuilder\My Books - SIS LLC",
  [string]$TemplateRoot = "E:\LocalClone\LocalClone\GitHub\Vera-FIXED-1\BookPressBuilder\templates",
  [string]$ChatMarkdown,                 # optional; if absent, you'll be prompted
  [string]$BookTitle,                    # optional; if absent, inferred or prompted
  [switch]$UnifyAB,
  [ValidateSet('Both','Chat','File')]
  [string]$TOCSource = 'Both',
  [switch]$AssumeYes,
  [switch]$DryRun                         # optional preview
)

# ------------------ UTIL ------------------
function Write-Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Write-Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Write-Err ($m){ Write-Host "[ERR ] $m" -ForegroundColor Red }
function New-Directory($p){ if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p | Out-Null } }
function Get-FileSha256($path){
  if (-not (Test-Path $path)) { return $null }
  (Get-FileHash -Path $path -Algorithm SHA256).Hash
}
function Slugify([string]$s){
  $s = $s -replace '[^\p{L}\p{Nd}]+' , '-' -replace '-+','-'
  $s.Trim('-').ToLowerInvariant()
}
function StripAB([string]$title){ ($title -replace '(\s*[-–—]\s*)?[AB]\s*:?$','').Trim() }
function Confirm-YN($prompt, [bool]$defaultYes=$true){
  if ($AssumeYes) { return $true }
  $suffix = "[Y/n]"
  if (-not $defaultYes) { $suffix = "[y/N]" }
  $resp = Read-Host "$prompt $suffix"
  if ([string]::IsNullOrWhiteSpace($resp)) { return $defaultYes }
  $val = $resp.Trim().ToLower()
  return ($val -eq 'y' -or $val -eq 'yes')
}

# ------------------ TEMPLATES ------------------
$TemplatePrimaryName = 'book_structure_template.md'
$TemplateMasterName  = 'master_book_structure_template.md'
if (-not (Test-Path $TemplateRoot)) { Write-Err "TemplateRoot not found: $TemplateRoot"; exit 1 }
$TemplatePrimary = Join-Path $TemplateRoot $TemplatePrimaryName
$TemplateMaster  = Join-Path $TemplateRoot $TemplateMasterName
if ((-not (Test-Path $TemplatePrimary)) -and (-not (Test-Path $TemplateMaster))){
  Write-Err "Templates not found in $TemplateRoot"; exit 1
}
$TemplateChosenPath = $TemplateMaster
if (-not (Test-Path $TemplateChosenPath)) { $TemplateChosenPath = $TemplatePrimary }
$TemplateChosenName = Split-Path $TemplateChosenPath -Leaf
$TemplateText = Get-Content -Raw -Path $TemplateChosenPath
Write-Info ("Using template: {0}" -f $TemplateChosenName)

# ------------------ BOOK FOLDER / CHAT FILE PICKER ------------------
if ([string]::IsNullOrWhiteSpace($ChatMarkdown)) {
  if (-not (Test-Path $ProjectRoot)) { Write-Err "ProjectRoot not found: $ProjectRoot"; exit 1 }
  $bookFolders = Get-ChildItem -Path $ProjectRoot -Directory | Sort-Object Name
  if ($bookFolders.Count -eq 0) { Write-Err "No subfolders found under $ProjectRoot"; exit 1 }

  Write-Host "`nSelect a book folder:" -ForegroundColor Green
  for($i=0; $i -lt $bookFolders.Count; $i++){ Write-Host ("[{0}] {1}" -f $i, $bookFolders[$i].Name) }
  $idx = Read-Host "Enter number"
  if (-not ($idx -as [int])) { Write-Err "Invalid selection."; exit 1 }
  $idx = [int]$idx
  if ($idx -lt 0 -or $idx -ge $bookFolders.Count){ Write-Err "Selection out of range."; exit 1 }

  $SelectedBookFolder = $bookFolders[$idx].FullName

  # Default chat file candidates
  $defaultPattern1 = "Chat_*.md"
  $defaultPattern2 = "chat_dump.md"
  $chatCandidates = @(Get-ChildItem -Path $SelectedBookFolder -Filter $defaultPattern1 -File -ErrorAction SilentlyContinue) + @(Get-ChildItem -Path $SelectedBookFolder -Filter $defaultPattern2 -File -ErrorAction SilentlyContinue)
  if ($chatCandidates.Count -eq 0) {
    $chatCandidates = Get-ChildItem -Path $SelectedBookFolder -Filter "*.md" -File -ErrorAction SilentlyContinue
  }
  if ($chatCandidates.Count -eq 0) {
    Write-Err "No .md chat file found in $SelectedBookFolder. Please create your chat dump and re-run."
    exit 1
  }

  Write-Host "`nSelect chat file:" -ForegroundColor Green
  for($j=0; $j -lt $chatCandidates.Count; $j++){ Write-Host ("[{0}] {1}" -f $j, $chatCandidates[$j].Name) }
  $jdx = Read-Host "Enter number"
  if (-not ($jdx -as [int])) { Write-Err "Invalid selection."; exit 1 }
  $jdx = [int]$jdx
  if ($jdx -lt 0 -or $jdx -ge $chatCandidates.Count){ Write-Err "Selection out of range."; exit 1 }

  $ChatMarkdown = $chatCandidates[$jdx].FullName

  if ([string]::IsNullOrWhiteSpace($BookTitle)) {
    # Try to infer title from folder name: Book_Life_Recipes_Success -> Life Recipes Success
    $folderName = Split-Path $SelectedBookFolder -Leaf
    $titleGuess = $folderName -replace '^Book[_\- ]*',''
    $titleGuess = ($titleGuess -replace '[_\-]+',' ').Trim()
    $BookTitle = Read-Host ("Book title? (default: {0})" -f $titleGuess)
    if ([string]::IsNullOrWhiteSpace($BookTitle)) { $BookTitle = $titleGuess }
  }
} else {
  $SelectedBookFolder = Split-Path -Parent -Path $ChatMarkdown
  if ([string]::IsNullOrWhiteSpace($BookTitle)) {
    $folderName = Split-Path $SelectedBookFolder -Leaf
    $BookTitle = ($folderName -replace '^Book[_\- ]*','' -replace '[_\-]+',' ').Trim()
  }
}

# ------------------ OUTPUTS (overwrite in fixed path) ------------------
$BuildRoot  = Join-Path $SelectedBookFolder "Chat_Book_Build"
New-Directory $BuildRoot
$OutputBook   = Join-Path $BuildRoot ($BookTitle.Replace(':',' -') + '.md')
$ManifestPath = Join-Path $BuildRoot 'manifest.json'
$ReportPath   = Join-Path $BuildRoot 'BuildReport.md'
$PlanPath     = Join-Path $BuildRoot 'BuildPlan.json'

Write-Info "Book folder : $SelectedBookFolder"
Write-Info "Chat file   : $ChatMarkdown"
Write-Info "Book title  : $BookTitle"
Write-Info "Output root : $BuildRoot"

# ------------------ LOAD CHAT ------------------
if (-not (Test-Path $ChatMarkdown)) { Write-Err "Chat markdown not found: $ChatMarkdown"; exit 1 }
$ChatRaw = Get-Content -Path $ChatMarkdown -Raw
$ChatLines = ($ChatRaw -split "`r?`n")
$ChatLinesRev = @($ChatLines); [Array]::Reverse($ChatLinesRev)

# ------------------ PARSE SECTIONS ------------------
$SectionHeadingRegex = '^(?<hash>#{1,6})\s+(?<title>.+)$'
$sections = @{}
$currentTitle = $null
$currentContent = New-Object System.Collections.Generic.List[string]

function Commit-Section($title, $contentRef) {
  if ([string]::IsNullOrWhiteSpace($title)) { return }
  $orig = $title.Trim()
  $base = StripAB $orig
  $slug = Slugify $base
  if (-not $sections.ContainsKey($slug)) {
    $obj = [ordered]@{ 
      TitleBase     = $base
      TitleOriginal = $orig
      Slug          = $slug
      HasA          = $false
      HasB          = $false
      ContentA      = $null
      ContentB      = $null
      ContentSingle = $null
    }
    if ($orig -match '\bA\s*:?\s*$') { $obj.HasA = $true; $obj.ContentA = ($contentRef -join "`n") }
    elseif ($orig -match '\bB\s*:?\s*$') { $obj.HasB = $true; $obj.ContentB = ($contentRef -join "`n") }
    else { $obj.ContentSingle = ($contentRef -join "`n") }
    $sections[$slug] = $obj
  }
}

$currentContent.Clear()
foreach($line in $ChatLinesRev){
  if ($line -match $SectionHeadingRegex) {
    Commit-Section -title $currentTitle -contentRef $currentContent
    $currentTitle = $Matches['title']
    $currentContent = New-Object System.Collections.Generic.List[string]
    $currentContent.Add($line)
  } else {
    $currentContent.Add($line)
  }
}
Commit-Section -title $currentTitle -contentRef $currentContent
Write-Info ("Parsed {0} unique section bases from chat" -f $sections.Count)

# ------------------ FIND LATEST TOC/OUTLINE ------------------
$TOCHeaderRegex = '^\s*#\s*Table of Contents\b|^\s*###\s*Table of Contents\b'
$OutlineHeaderRegex = '^\s*#\s*Outline\b|^\s*###\s*Outline\b'
function Parse-TOCBlockFromText([string]$text){
  $lines = $text -split "`r?`n"
  $list = New-Object System.Collections.Generic.List[string]
  $collect = $false
  foreach($l in $lines){
    if ($l -match $TOCHeaderRegex -or $l -match $OutlineHeaderRegex) { $collect = $true; continue }
    if ($collect -and $l -match '^\s*#\s+' ) { break }
    if ($collect) { $list.Add($l) }
  }
  return ($list -join "`n")
}
$TOCBlockChat = Parse-TOCBlockFromText $ChatRaw
$ChatTOCFound = -not [string]::IsNullOrWhiteSpace($TOCBlockChat)

$TOCFileGlob = '*toc*.md','*table-of-contents*.md','*outline*.md'
$TOCFileEntries = @()
foreach($glob in $TOCFileGlob){
  $TOCFileEntries += Get-ChildItem -Path $ProjectRoot -File -Recurse -Filter $glob -ErrorAction SilentlyContinue
}
$TOCFileEntry = $null
if ($TOCFileEntries) { $TOCFileEntry = ($TOCFileEntries | Sort-Object LastWriteTime -Descending | Select-Object -First 1) }

$TOCChosen = $null
$TOCSourceChosen = $null
if ($TOCSource -eq 'Chat' -and $ChatTOCFound) { $TOCChosen = $TOCBlockChat; $TOCSourceChosen='Chat' }
elseif ($TOCSource -eq 'File' -and $TOCFileEntry) { $TOCChosen = (Get-Content -Raw -Path $TOCFileEntry.FullName); $TOCSourceChosen="File:$($TOCFileEntry.FullName)" }
else {
  if ($ChatTOCFound) { $TOCChosen = $TOCBlockChat; $TOCSourceChosen='Chat' }
  elseif ($TOCFileEntry) { $TOCChosen = (Get-Content -Raw -Path $TOCFileEntry.FullName); $TOCSourceChosen="File:$($TOCFileEntry.FullName)" }
}

function Parse-TOCEntries([string]$tocText){
  $entries = New-Object System.Collections.Generic.List[Hashtable]
  if ([string]::IsNullOrWhiteSpace($tocText)) { return $entries }
  $lines = $tocText -split "`r?`n"
  foreach($l in $lines){
    if ($l -match '^\s*(?:[-*+]|\d+\.)\s*(?<t>.+)$'){ $t=$Matches['t'] }
    elseif ($l -match '^\s*#{1,6}\s*(?<t>.+)$'){ $t=$Matches['t'] }
    else { continue }
    $clean = ($t -replace '\.+\s*\d+\s*$','').Trim()
    if ($clean) { $entries.Add(@{ Raw=$l; Title=$clean; Slug=(Slugify (StripAB $clean)) }) }
  }
  return $entries
}
$tocEntries = Parse-TOCEntries $TOCChosen
Write-Info ("TOC entries discovered: {0}" -f $tocEntries.Count)

# ------------------ MAP ENTRIES ------------------
$resolved = New-Object System.Collections.Generic.List[Hashtable]
$missing = New-Object System.Collections.Generic.List[Hashtable]
foreach($e in $tocEntries){
  if ($sections.ContainsKey($e.Slug)){
    $s = $sections[$e.Slug]
    $choice = $null; $content = $null
    if ($s.ContentSingle){ $choice='Single'; $content=$s.ContentSingle }
    elseif ($s.HasA -and $s.HasB){
      if ($UnifyAB){ $choice='Merged'; $content = ($s.ContentA.TrimEnd()+"`n`n"+$s.ContentB.TrimStart()) }
      else {
        if (Confirm-YN ("For '{0}', choose A? (No = choose B)" -f $s.TitleBase) $true){
          $choice='A'; $content=$s.ContentA
        } else { $choice='B'; $content=$s.ContentB }
      }
    } elseif ($s.HasA){ $choice='A'; $content=$s.ContentA }
    elseif ($s.HasB){ $choice='B'; $content=$s.ContentB }
    $resolved.Add(@{ Title=$s.TitleBase; Slug=$s.Slug; Choice=$choice; Content=$content })
  } else {
    $missing.Add($e)
  }
}

if ($resolved.Count -eq 0 -and $sections.Count -gt 0){
  Write-Warn "TOC mapping empty; falling back to discovered chat sections (newest-first)."
  foreach($kv in $sections.GetEnumerator()){
    $s = $kv.Value
    $content = $s.ContentSingle
    $choice = 'Single'
    if (-not $content){
      if ($s.HasA -and $s.HasB -and $UnifyAB){ $choice='Merged'; $content=($s.ContentA.TrimEnd()+"`n`n"+$s.ContentB.TrimStart()) }
      elseif ($s.HasA){ $choice='A'; $content=$s.ContentA }
      elseif ($s.HasB){ $choice='B'; $content=$s.ContentB }
    }
    if ($content){ $resolved.Add(@{ Title=$s.TitleBase; Slug=$s.Slug; Choice=$choice; Content=$content }) }
  }
}

# ------------------ Normalization ------------------
function Normalize-Headings([string]$md){
  $out = New-Object System.Collections.Generic.List[string]
  $lines = $md -split "`r?`n"
  foreach($l in $lines){
    if ($l -match '^\s*##\s+' -and ($l -notmatch '^\s*#\s{1}')){ $l = $l -replace '^\s*##\s+','### ' }
    $out.Add($l.TrimEnd())
  }
  return ($out -join "`n")
}
function Ensure-BlankLine-Before-Lists([string]$md){
  $lines = $md -split "`r?`n"
  $out = New-Object System.Collections.Generic.List[string]
  for($i=0; $i -lt $lines.Count; $i++){
    $curr = $lines[$i]; $prev = $(if ($i -gt 0) { $lines[$i-1] } else { '' })
    if ($curr -match '^\s*([-*+]|\d+\.)\s+' -and $prev -match '\S'){ $out.Add("") }
    $out.Add($curr)
  }
  return ($out -join "`n")
}
function Add-AnchorIds([string]$md){
  $lines = $md -split "`r?`n"
  $out = New-Object System.Collections.Generic.List[string]
  foreach($l in $lines){
    if ($l -match '^(?<h>#{1,6})\s+(?<t>.+)$'){
      $h=$Matches['h']; $t=$Matches['t']
      if ($t -notmatch '\{#.+\}\s*$'){
        $slug = Slugify (StripAB $t); $l = "$h $t {#$slug}"
      }
    }
    $out.Add($l)
  }
  return ($out -join "`n")
}
function Normalize-EPUB([string]$md){
  $md = Normalize-Headings $md
  $md = Ensure-BlankLine-Before-Lists $md
  $md = Add-AnchorIds $md
  return $md
}

# ------------------ Plan/Report ------------------
$Plan = [ordered]@{
  book_title = $BookTitle
  template_used = $TemplateChosenName
  toc_source = $TOCSource
  output_dir = $BuildRoot
  chapters_preview = @($resolved | ForEach-Object { @{ title=$_.Title; choice=$_.Choice } })
  missing = @($missing | ForEach-Object { $_.Title })
}
$Plan | ConvertTo-Json -Depth 6 | Set-Content -Path $PlanPath -Encoding UTF8

$Report = @()
$Report += "# Build Report"
$Report += ""
$Report += ("**Book:** {0}" -f $BookTitle)
$Report += ("**Template:** {0}" -f $TemplateChosenName)
$Report += ("**TOC Source:** {0}" -f $TOCSource)
$Report += ("**Sections discovered:** {0}" -f $sections.Count)
$Report += ("**Chapters resolved:** {0}" -f $resolved.Count)
if ($missing.Count -gt 0){
  $Report += ""
  $Report += "## Missing from TOC mapping"
  foreach($m in $missing){ $Report += ("- {0}" -f $m.Title) }
}
$Report | Set-Content -Path $ReportPath -Encoding UTF8

if ($DryRun){
  Write-Info "DRY RUN -> Plan: $PlanPath"
  Write-Info "DRY RUN -> Report: $ReportPath"
  Write-Info "No book written because -DryRun was supplied."
  exit 0
}

# ------------------ BUILD (default) ------------------
$tpl = $TemplateText
$tpl = $tpl -replace '\{\{BOOK_TITLE\}\}',$BookTitle.Replace('\','\\')
$tpl = $tpl -replace '\{\{BUILD_DATE\}\}',(Get-Date)
# PowerShell 5.1 doesn't have ??; emulate
$TOCSourceSafe = $TOCSource
if ([string]::IsNullOrWhiteSpace($TOCSourceSafe)) { $TOCSourceSafe = 'None' }
$tpl = $tpl -replace '\{\{TOC_SOURCE\}\}',$TOCSourceSafe

$composed = New-Object System.Text.StringBuilder
foreach($ch in $resolved){
  $content = $ch.Content
  if (-not [string]::IsNullOrWhiteSpace($content)){
    $fixed = Normalize-EPUB $content
    [void]$composed.AppendLine($fixed)
    [void]$composed.AppendLine()
  }
}

$FinalMD = $tpl
if ($FinalMD -match '\{\{CONTENT\}\}'){
  $escaped = [Regex]::Escape($composed.ToString()).Replace('\','\\')
  $FinalMD = $FinalMD -replace '\{\{CONTENT\}\}',$escaped
} else {
  $FinalMD = ($FinalMD.TrimEnd() + "`n`n" + $composed.ToString())
}

$FinalMD | Set-Content -Path $OutputBook -Encoding UTF8

$manifest = [ordered]@{
  book_title = $BookTitle
  project_root = $ProjectRoot
  template_root = $TemplateRoot
  template_used = $TemplateChosenName
  toc_source = $TOCSource
  chat_path = $ChatMarkdown
  output_book = $OutputBook
  report_path = $ReportPath
  timestamp = (Get-Date).ToString('o')
  hashes = [ordered]@{
    template_sha256 = Get-FileSha256 $TemplateChosenPath
    chat_sha256     = Get-FileSha256 $ChatMarkdown
    output_sha256   = Get-FileSha256 $OutputBook
  }
  chapters = $resolved
  missing  = $missing
  tp_notes = "Build-by-default. Latest-first selection from chat (bottom-up). A/B unified=$($UnifyAB.IsPresent). Headings normalized to ###. Blank lines before lists ensured. Anchors added. Output rooted at <BookFolder>\Chat_Book_Build (overwrite)."
}
$manifest | ConvertTo-Json -Depth 6 | Set-Content -Path $ManifestPath -Encoding UTF8

Write-Info ("WROTE   : {0}" -f $OutputBook)
Write-Info ("MANIFEST: {0}" -f $ManifestPath)
Write-Info ("REPORT  : {0}" -f $ReportPath)
