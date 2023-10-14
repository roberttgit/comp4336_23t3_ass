# INPUT FILES 
#Text files from capture script.
$inputdirectory  = "C:\Users\Robert\Documents\comp4336\ass\extracteddata\cliout"
#BSSID - SSID - Width lookup table from Netspot export
$netspotfilepath = "C:\Users\Robert\Documents\comp4336\ass\extracteddata\netspot\netspot_unique.csv"


# WORK FILES & OUTPUT FILES
#Output of conversion from (Text files from capture program) -> (CSV)
#Please clear this directory's contents before running the script.
$outputdirectory = "C:\Users\Robert\Documents\comp4336\ass\extracteddata\csvout1"
#Concatenation of CSV Data
$workfilepath    = "C:\Users\Robert\Documents\comp4336\ass\extracteddata\csvout2\workfile.csv"
#Unique rows from concatenated CSV Data
$outfilepath1    = "C:\Users\Robert\Documents\comp4336\ass\extracteddata\csvout2\concatenated_data1.csv"
#Unique concatenated CSV data, with Channel Width added (reference on BSSID)
$outfilepath2    = "C:\Users\Robert\Documents\comp4336\ass\extracteddata\csvout2\concatenated_data2.csv"
#Unique concatenated CSV data, with Channel Width added (reference on BSSID and SSID), with OS and wlanInterface added
$outfilepath3    = "C:\Users\Robert\Documents\comp4336\ass\extracteddata\csvout2\concatenated_data3.csv"

# MANUALLY ENTERED DETAILS - to go into the CSV
$operatingSystem= "Windows 11"
$wlanInterface  = "Intel Wi-Fi 6 AX200"


# EXTERNAL SCRIPTS
#The Python script which converts the Text file from capture program to a CSV
$script_location = "C:\Users\Robert\Documents\comp4336\ass\scripts\asswifi.py"


# NOTES / REMARKS
#This script can take a while to run!! It can take 20-30 minutes to process the data from ~180 captures on the UNSW campus.
#(on Intel i7-10700K, using one core.)
#Go and drink coffee after you begin the execution.

############################################################################################################
# #generate csv for each txt
# if (-not (Test-Path -Path $outputdirectory)) {
#     New-Item -Path $outputdirectory -ItemType Directory -Force
# }

# Get-ChildItem -File -Path $inputdirectory | Foreach {$fn = $_.fullname; $n = $_.name; py `"$script_location`" `"$fn`" `"$outputdirectory`\$n`"}

# #concatenate all of the csv and remove duplicates
# $contentList = @()

# $allInputCSVFiles = Get-ChildItem -Path $outputdirectory -Recurse -Filter *.csv
# foreach ($file in $allInputCSVFiles) {
#     $content = Import-Csv -Path $file.FullName
#     $contentList += $content
# }

# if (Test-Path -Path $workFilePath) {
#     rm $workFilePath -Force
# }
# if (Test-Path -Path $outfilepath1) {
#     rm $outfilepath1 -Force
# }
# New-Item -ItemType File -Path $workFilePath -Force
# New-Item -ItemType File -Path $outfilepath1 -Force

# foreach ($csvFile in $allInputCSVFiles) {
#     $csvContent = Import-Csv -Path $csvFile.FullName
#     $contentList += $csvContent
# }

# $mergedCsvContent = $contentList | ConvertTo-Csv -NoTypeInformation
# $mergedCsvContent | Out-File -FilePath $workfilepath -Encoding UTF8

# $uniqueLines = Get-Content $workfilepath | Select-Object -Unique
# $uniqueLines | Set-Content $outfilepath1

# #add the Channel Width info
# $catCsv = Import-Csv -Path $outfilepath1
# $netspotCsv = Import-Csv -Path $netspotfilepath

# foreach ($catRow in $catCsv) {
#     $bssid = $catRow.BSSID
#     $ssid = $catRow.SSID

#     $bssidWidth = ($netspotCsv | Where-Object { $_.BSSID -eq $bssid }).Width
#     $catRow | Add-Member -MemberType NoteProperty -Name "Width" -Value $bssidWidth
# }
# $catCsv | Export-Csv -Path $outfilepath2 -NoTypeInformation

# Where there is a BSSID corresponding to two SSID, choose the width of the BSSID for the correct SSID (Match on BSSID, SSID)
$catCsv = Import-Csv -Path $outfilepath2
$netspotCsv = Import-Csv -Path $netspotfilepath

foreach ($catRow in $catCsv) {
    if (($catRow.Width).Length -gt 3) {
        $bssid = $catRow.BSSID
        $ssid = $catRow.SSID

        $bssidWidth = ($netspotCsv | Where-Object { ($_.BSSID -eq $bssid) -and ($_.SSID -eq $ssid) }).Width
        $catRow.Width = $bssidWidth
    }
}

$catCsv2 = ($catCsv | Where-Object { $_.Width -ne '' })

#Add the OS and WLAN Interface info
foreach ($catRow in $catCsv2) {
    $catRow | Add-Member -MemberType NoteProperty -Name "OS" -Value $operatingSystem
    $catRow | Add-Member -MemberType NoteProperty -Name "Interface" -Value $wlanInterface
}
$catCsv2 | Export-Csv -Path $outfilepath3 -NoTypeInformation

