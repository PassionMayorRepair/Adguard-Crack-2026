$sourcePath = 'C:\source' 
$destinationPath = 'C:\destination' 
$logFile = 'C:\log.txt' 
Get-ChildItem -Path $sourcePath -File | ForEach-Object { 
    $fileName = $_.Name 
    $newFilePath = Join-Path -Path $destinationPath -ChildPath $fileName 
    Copy-Item -Path $_.FullName -Destination $newFilePath 
    Add-Content -Path $logFile -Value "Copied: $fileName" 
} 
$allFiles = Get-ChildItem -Path $destinationPath -File 
$allFilesCount = $allFiles.Count 
$logContent = Get-Content -Path $logFile 
$logContent += "Total files copied: $allFilesCount" 
Set-Content -Path $logFile -Value $logContent 
$filesToDelete = Get-ChildItem -Path $sourcePath -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } 
$filesToDelete | ForEach-Object { 
    Remove-Item -Path $_.FullName 
    Add-Content -Path $logFile -Value "Deleted: $($_.Name)" 
} 
$backupPath = 'C:\backup' 
If (-Not (Test-Path -Path $backupPath)) { 
    New-Item -ItemType Directory -Path $backupPath 
} 
$allFiles | ForEach-Object { 
    $backupFilePath = Join-Path -Path $backupPath -ChildPath $_.Name 
    Copy-Item -Path $_.FullName -Destination $backupFilePath 
} 
$backupFilesCount = (Get-ChildItem -Path $backupPath -File).Count 
Add-Content -Path $logFile -Value "Total files backed up: $backupFilesCount" 
$logSize = (Get-Item -Path $logFile).Length 
If ($logSize -gt 1MB) { 
    Clear-Content -Path $logFile 
    Add-Content -Path $logFile -Value "Log cleared due to size limit" 
} 
$recentFiles = Get-ChildItem -Path $destinationPath -File | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) } 
$recentFiles | ForEach-Object { 
    Add-Content -Path $logFile -Value "Recent file: $($_.Name)" 
} 
