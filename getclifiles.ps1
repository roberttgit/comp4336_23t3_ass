# INPUT DIRECTORY
#The parent directory containing all the text files generated from the capture script.
$sourceDirectory  = "C:\Users\Robert\Documents\comp4336\ass\rawdata",

# OUTPUT DIRECTORY
#The directory in which to output all the text files found by this script.
$cliTextDirectory = "C:\Users\Robert\Documents\comp4336\ass\extracteddata\cliout"

############################################################################################################
if (-not (Test-Path -Path $cliTextDirectory)) {
    New-Item -Path $cliTextDirectory -ItemType Directory -Force
}


# Recursively get all .txt files in the source directory
$clifiles = Get-ChildItem -Path $sourceDirectory -Recurse -Include *.txt

$clifiles

# Copy each .txt file to the destination directory
foreach ($file in $clifiles) {
    $destinationPath = Join-Path -Path $cliTextDirectory -ChildPath $file.Name
    Copy-Item -Path $file.FullName -Destination $destinationPath
    Write-Host "Copied $($file.FullName) to $($destinationPath)"
}

