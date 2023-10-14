
#time
echo "================TIMESTAMP================"

$DateTime = (Get-Date).ToUniversalTime()
$DateTime
$UnixTimeStamp = [System.Math]::Truncate((Get-Date -Date $DateTime -UFormat %s))
$UnixTimeStamp

# wlans info 
echo "================BSSID INFORMATION================"
netsh wlan show networks mode=bssid
echo "================INTERFACE INFORMATION================"
netsh wlan show interfaces

#get GPS details from the WWAN card
echo "================GPS INFORMATION================"

Add-Type -AssemblyName System.Device
$GeoWatcher = New-Object System.Device.Location.GeoCoordinateWatcher
$GeoWatcher.Start()

$GeoWatcher

Start-Sleep -Milliseconds 25000 #Wait to start the thing
while (($GeoWatcher.Status -ne 'Ready') -and ($GeoWatcher.Permission -ne 'Denied')) {
    Start-Sleep -Milliseconds 4000 #Card is being lazy so let's wait some more
}  

if ($GeoWatcher.Permission -eq 'Denied'){
	Write-Error 'Access Denied for Location Information'
} else {
	$GeoWatcher.Position.Location | Select *
}

#network latency - cse
echo "================PING TEST================"
ping cse.unsw.edu.au -n 4

#public IP
echo "================PUBLIC IP================"
curl ifconfig.me

#Ending line
echo "================END OF AUTOMATICALLY CAPTURED DATA================"

echo "================BEGIN MANUAL ENTRY SECTION================"