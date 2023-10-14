# INPUT DIRECTORY
#The parent directory containing all the CSV files from the Netspot exports.
$sourceFilePath = "C:\Users\Robert\Documents\comp4336\ass\rawdata"

# WORK FILE
#Concatenation of CSV files.
$workFilePath   = "C:\Users\Robert\Documents\comp4336\ass\extracteddata\netspot\netspot_all.csv"

# OUTPUT FILE
#CSV file containing the unique rows found in the work file.
$outputFilePath = "C:\Users\Robert\Documents\comp4336\ass\extracteddata\netspot\netspot_unique.csv"

############################################################################################################

$contentList = @()

$allInputFiles = Get-ChildItem -Path $sourceFilePath -Recurse -File -Filter "all_networks.csv"
$allInputFiles

foreach ($file in $allInputFiles) {
    $content = Import-Csv -Path $file.FullName
    $contentList += $content
}

if (Test-Path -Path $workFilePath) {
    rm $workFilePath -Force
}
if (Test-Path -Path $outputFilePath) {
    rm $outputFilePath -Force
}
New-Item -ItemType File -Path $workFilePath -Force
New-Item -ItemType File -Path $outputFilePath -Force

[string]$header = "`"BSSID`",`"SSID`",`"Width`""
Add-Content -Path $workFilePath -Value $header

foreach ($content in $contentList) {
    [string]$contentbssid = $content."BSSID (MAC Address)"
    [string]$contentssid = $content."SSID (Network name)"
    [string]$contentwidth = $content."Channel width (MHz)"

    [string]$contentstr = "`"$contentbssid`",`"$contentssid`",`"$contentwidth`""
    Add-Content -Path $workFilePath -Value $contentstr
}

$uniqueLines = Get-Content $workfilepath | Select-Object -Unique
$uniqueLines | Set-Content $outputFilePath