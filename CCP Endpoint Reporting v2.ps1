#---------------------------------------
#	Written by Sean May - CyberArk
#	December 6, 2018
#	Version 2
#	Note: This is not an official
#	CyberArk utility.
#---------------------------------------

$installDir = "unknown"

function Find-SavePath {
    [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $browse = New-Object System.Windows.Forms.FolderBrowserDialog
    $browse.SelectedPath = "C:\"
    $browse.ShowNewFolderButton = $true
    $browse.Description = "Select a directory where the report will be placed"

    $loop = $true
    while($loop)
    {
        if ($browse.ShowDialog() -eq "OK")
        {
        $loop = $false
				
        } else
        {
            $res = [System.Windows.Forms.MessageBox]::Show("You clicked Cancel. Would you like to try again or exit?", "Select a location", [System.Windows.Forms.MessageBoxButtons]::RetryCancel)
            if($res -eq "Cancel")
            {
                #Ends script
                return
            }
        }
    }
    $browse.SelectedPath
    $browse.Dispose()
}

function Find-InstallDir {

    if (Test-Path "D:\Program Files (x86)\CyberArk\ApplicationPasswordProvider\Logs\") {
        Set-Variable installDir "D:\Program Files (x86)\CyberArk\ApplicationPasswordProvider\Logs\"
        } elseif (Test-Path "C:\Program Files (x86)\CyberArk\ApplicationPasswordProvider\Logs\") {
            Set-Variable installDir "C:\Program Files (x86)\CyberArk\ApplicationPasswordProvider\Logs\"
        } else {
                Set-Variable installDir "unknown"
        }
    $installDir
}

function Find-LogPath($installDir) {

    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $installDir
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename

}

Set-Variable savePath (Find-SavePath)
$savePath = $savePath + "\CCP.csv"

Set-Variable installDir (Find-InstallDir)

if ($installDir -contains "unknown") {
    Read-Host "Please hit Enter to choose the location of your AppAudit.log file"
    Set-Variable logPath (Find-LogPath $installDir)
    } else {
        $logPath = $installDir + "\AppAudit.log"
        }

Write-Host "The report will be saved to: " $savePath
Write-Host "The log will be pulled from: " $logPath

# Parse the log file
$addressPattern = '(?<=IP address \[).+?(?=\])'

$data = Get-Content -Path $logPath | Where-Object {$_ -Match '.*APPAU005I.*'}
$addresses = $data | Select-String $addressPattern -AllMatches
$uniqueAddresses = $addresses.Matches.Value | select -uniq

# Output
Write-Host "`n"
Write-Host "Unique addresses found:`n"
$uniqueAddresses
Write-Host "`n"
Write-Host ("Total count of unique addresses: " + $uniqueAddresses.Count)

foreach($item1 in $uniqueAddresses) 
{ 
  $csv_string = "";
  foreach($item in $item1)
  {
    $csv_string = $csv_string + $item;
  }
  Set-Content $savePath $csv_string;
}

Read-Host -Prompt “`nPress Enter to exit”
