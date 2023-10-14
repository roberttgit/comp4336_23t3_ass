$text_editor = "C:\windows\system32\notepad.exe"

$filename_timestamp = Get-Date -format "yyyy-MM-dd-HH-mm-ss"
$foldername = "$filename_timestamp"
$filename = "$filename_timestamp.txt"
$folderpath = ".\results\$foldername"
mkdir $folderpath
$filepath = ".\results\$foldername\$filename"
.\wlananalysis.ps1 >> $filepath

cat $filepath | findstr "Latitude Longitude HorizontalAccuracy"

#echo "!!! Ready for manual NetSpot input !!!"
#echo "Please copy the NetSpot data to the Notepad."

#echo "Ready to input the data?"
#Write-Host -NoNewline -Object 'Press any key to continue...' -ForegroundColor Yellow
#$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

#Start-Process $text_editor $filepath