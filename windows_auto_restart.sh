$lastBootUpTime = (Get-CimInstance -ClassName
Win32_OperatingSystem).LastBootUpTime
$currentTime = Get-Date
$daysSinceLastReboot = ($currentTime - $lastBootUpTime).Days

# Define the threshold (7 days)
$thresholdDays = 2

if ($daysSinceLastReboot -gt $thresholdDays) { 
    # Define message box parameters
    $MessageTitle = "Restart Required"
    $MessageBody = "Your computer hasn't been rebooted in $7 days. Please restart your machine at your earliest convenience."
$ButtonType = [System.Windows.MessageBoxButton]::OK
$MessageIcon = [System.Windows.MessageBoxImage]::Warning

# Load Windows Forms Assembly to display the pop-up [void][System.Reflection.Assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089') [void][System.Windows.MessageBox]::Show("$MessageBody", "$MessageTitle", "$ButtonType", "$MessageIcon") 
}