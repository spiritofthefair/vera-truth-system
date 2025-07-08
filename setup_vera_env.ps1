# PowerShell Script to prepare Vera local environment
$logsPath = "E:\LocalClone\Vera\vera-truth-system\logs"
$apiPath = "E:\LocalClone\Vera\vera-truth-system\api\vera_api_production.py"
$envFile = "$logsPath\env_launch.log"

# Create logs directory if it doesn't exist
if (-Not (Test-Path -Path $logsPath)) {
    New-Item -Path $logsPath -ItemType Directory | Out-Null
    Write-Output "✅ Created logs directory: $logsPath"
} else {
    Write-Output "✅ Logs directory exists: $logsPath"
}

# Create placeholder log files if missing
$logFiles = @("env_launch.log", "api_startup.log", "mission_history.json", "service_index.json")
foreach ($file in $logFiles) {
    $filePath = Join-Path $logsPath $file
    if (-Not (Test-Path $filePath)) {
        New-Item -Path $filePath -ItemType File | Out-Null
        Write-Output "✅ Created: $filePath"
    } else {
        Write-Output "✔ Already exists: $filePath"
    }
}

# Confirm the API script path
if (-Not (Test-Path $apiPath)) {
    Write-Output "❌ ERROR: vera_api_production.py NOT FOUND"
} else {
    Write-Output "✅ API script found: $apiPath"
}