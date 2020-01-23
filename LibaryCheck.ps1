param (
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$dir,
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [Int]$threads = 4,
    [int]$min = 5
)
$startTime = Get-Date
$dateString = $startTime.ToString("yyyyMMddmmss")
$min = $min * 1000000

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$handbrakePath = $scriptPath + "\HandBrakeCLI.exe"

if (!(Test-Path $handbrakePath)) {
    Write-Output "`nYou need to download HandBrakeCLI.exe and place it in the same directory as this script. `nDownload link: https://handbrake.fr/downloads2.php `nPress N to close the script or Y to open the above link to download."
    do {
        $keyPress = [System.Console]::ReadKey()
    }
    until ($keyPress.Key -eq "Y" -or $keyPress.Key -eq "N")
    if ($keyPress.Key -eq "Y") {
        Start-Process 'https://handbrake.fr/downloads2.php'
        Write-Output "`n"
        exit
    } else {
        Write-Output "`n"
        exit
    }
}

if ($threads -gt 4) {
    Write-Output "`nWARNING: Selecting more than 4 threads may lock up your computer. Press N to set threads to 4 or press Y to continue..."
    do {
        $keyPress = [System.Console]::ReadKey()
    }
    until ($keyPress.Key -eq "Y" -or $keyPress.Key -eq "N")
    if ($keyPress.Key -eq "N") {
        $threads = 4
    }
}

$currentDirectory = $dir
Write-Output "`nScanning $currentDirectory..."

$errorLogName = "error$dateString.log"
$goodLogName = "good$dateString.log"
$csvLogName = "$dateString.csv"

$csvLogPath = $scriptPath + "\$csvLogName"
$errorLogPath = $scriptPath + "\$errorLogName"
$goodLogPath = $scriptPath + "\$goodLogName "

Write-Output "Creating log files"
Set-Content $csvLogPath -Value "File,Result"
New-Item -path $scriptPath -name $errorLogName -type "file" | Out-Null
New-Item -path $scriptPath -name $goodLogName -type "file" | Out-Null
$countStartTime = Get-Date
Write-Output "Counting items..."

$unfilteredFiles = Get-ChildItem "$currentDirectory" *.* -R -File
$files = ($unfilteredFiles | Where-Object {$_.Length -gt $min}).FullName
$totalItems = $files.Count
$countFinishTime = Get-Date
$countTotalTime = $countFinishTime - $countStartTime
Write-Output "$totalItems items detected in $([int]$countTotalTime.Seconds) seconds"
$completedItems = 0
Write-Output "Scanning in progress..."

$scriptBlock = {
    Param($file, $handbrake, $errorLog, $goodLog, $csvLog)
    $cmtx = new-object System.Threading.Mutex($false, "CSVLogFileAccessMTX")
    $result = &$handbrake -i $file --scan 2>&1 | Out-String
    if ($result.Contains("EBML header parsing failed")) {
        $errorMessage = "EBML header parsing failed (highly likely won't play)"
        $emtx = new-object System.Threading.Mutex($false, "ErrorLogFileAccessMTX")
        $emtx.WaitOne(5000)
        "$file | $errorMessage" >> "$errorLog"
        $emtx.ReleaseMutex()
        $cmtx.WaitOne(5000)
        [PSCustomObject]@{
            'File' = $file
            'Result' = $errorMessage
        } | Export-Csv -append -path $csvLog
        $cmtx.ReleaseMutex()
    }
    elseif ($result.Contains("Read error at pos. 1 (0x1)")) {
        $errorMessage = "Read error at pos. 1 (0x1) (highly likely won't play)"
        $emtx = new-object System.Threading.Mutex($false, "ErrorLogFileAccessMTX")
        $emtx.WaitOne(4000)
        "$file | $errorMessage" >> "$errorLog"
        $emtx.ReleaseMutex()
        $cmtx.WaitOne(5000)
        [PSCustomObject]@{
            'File' = $file
            'Result' = $errorMessage
        } | Export-Csv -append -path $csvLog
        $cmtx.ReleaseMutex()
    }
    elseif ($result.Contains("Read error")) {
        $errorMessage = "Read error (usually will still play)"
        $emtx = new-object System.Threading.Mutex($false, "ErrorLogFileAccessMTX")
        $emtx.WaitOne(3000)
        "$file | $errorMessage" >> "$errorLog"
        $emtx.ReleaseMutex()
        $cmtx.WaitOne(5000)
        [PSCustomObject]@{
            'File' = $file
            'Result' = $errorMessage
        } | Export-Csv -append -path $csvLog
        $cmtx.ReleaseMutex()
    } elseif ($result.Contains("scan: unrecognized file type")) {
        $errorMessage = "Unrecognized file type (highly likely won't play)"
        $emtx = new-object System.Threading.Mutex($false, "ErrorLogFileAccessMTX")
        $emtx.WaitOne(3000)
        "$file | $errorMessage" >> "$errorLog"
        $emtx.ReleaseMutex()
        $cmtx.WaitOne(5000)
        [PSCustomObject]@{
            'File' = $file
            'Result' = $errorMessage
        } | Export-Csv -append -path $csvLog
        $cmtx.ReleaseMutex()
    } else {
        $errorMessage = "OK!"
        $gmtx = new-object System.Threading.Mutex($false, "GoodLogFileAccessMTX")
        $gmtx.WaitOne(100)
        "$file | $errorMessage" >> "$goodLog"
        $gmtx.ReleaseMutex()
        $cmtx.WaitOne(5000)
        [PSCustomObject]@{
            'File' = $file
            'Result' = $errorMessage
        } | Export-Csv -append -path $csvLog
        $cmtx.ReleaseMutex()
    } 
}

$files | ForEach-Object {
    $completedItems++
    $running = @(Get-Job | Where-Object { $_.State -eq 'Running' })
    if ($running.Count -ge $threads) {
        $running | Wait-Job -Any | Out-Null
    }

    Start-Job -Scriptblock $scriptblock -ArgumentList @($_, $handbrakePath, $errorLogPath, $goodLogPath, $csvLogPath) | Out-Null
    if ($totalItems -ne 0) {
        Write-Progress -Activity "Scan" -Status "Progress($completedItems/$totalItems) - $_" -PercentComplete ($completedItems / $totalItems * 100)
    }
}

# Wait for all jobs to complete and results ready to be received
Wait-Job * | Out-Null

Write-Progress -Activity "Scan" -Status "Progress($completedItems/$totalItems):" -Completed
$totalErrors = (Get-Content $errorLogPath | Measure-Object -Line).Lines
$finishTime = Get-Date
$timeTaken = $finishTime - $startTime

Remove-Job -State Completed

Write-Output "Scan took $($timeTaken.Days) Days $($timeTaken.Hours) Hours $($timeTaken.Minutes) Minutes $($timeTaken.Seconds) Seconds"
Write-Output "$($totalErrors) files with problems. Refer to $errorLogName for a list of problem files, $goodLogName for good files and $csvLogName for a spreadsheet of all files."