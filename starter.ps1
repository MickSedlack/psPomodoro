$commpath = '"C:\Users\Mick\Documents\Projects\psPomodoro\pomodoro.ps1"'
$strCommand = "powershell -WindowStyle hidden -file $($commpath)"

Invoke-Expression $strCommand