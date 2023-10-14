
# INPUT FILES 
#Text files from capture script.
$cliLogDirectory = "C:\Users\Robert\Documents\comp4336\ass\extracteddata\cliout"

# OUTPUT FILE
#CSV file containing the GPS data.
$GPSDataFilePath = "C:\Users\Robert\Documents\comp4336\ass\extracteddata\gps\gps.csv"

############################################################################################################

if (Test-Path -Path $GPSDataFilePath) {
    rm $GPSDataFilePath -Force
}
New-Item -ItemType File -Path $GPSDataFilePath -Force

$clifiles = Get-ChildItem -Path $cliLogDirectory -Recurse -Include *.txt

[string]$header = "`"WindowsTime`",`"UnixTime`",`"Latitude`",`"Longitude`",`"HorizontalAccuracy`""
Add-Content -Path $GPSDataFilePath -Value $header

foreach ($file in $clifiles) {
    $windowstime = ($file.Name).replace(".txt","")
    $filecontent = Get-Content $file
    $unixtime = ($filecontent | Select-Object -Index 3).Trim()
    $latitude = $filecontent | Select-String -Pattern 'Latitude\s+:\s+(-?\d+(\.\d+)?)' | ForEach-Object { $_.Matches.Groups[1].Value }
    $longitude = $filecontent | Select-String -Pattern 'Longitude\s+:\s+(-?\d+(\.\d+)?)' | ForEach-Object { $_.Matches.Groups[1].Value }
    $horizontalAccuracy = $filecontent | Select-String -Pattern 'HorizontalAccuracy\s+:\s+(-?\d+(\.\d+)?)' | ForEach-Object { $_.Matches.Groups[1].Value }

    [string]$contentstr = "`"$windowstime`",`"$unixtime`",`"$latitude`",`"$longitude`",`"$horizontalAccuracy`""
    Add-Content -Path $GPSDataFilePath -Value $contentstr
}

