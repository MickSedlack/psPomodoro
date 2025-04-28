Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
#invoking powertoys hotkey for Always On Top

$Form                            		= New-Object system.Windows.Forms.Form
$Form.ClientSize                	= '275,175'
$Form.text							= "Pomodoro"
$Form.BackColor                	= "#f7f5dd"
$Form.TopMost                  	= $false

$CLock                          		= New-Object system.Windows.Forms.Label
$CLock.text 						= "The time is?"
$CLock.BackColor				= "#f7f5dd"
$CLock.AutoSize					= $true
$CLock.width						= 25
$CLock.height						= 10
$CLock.location					= New-Object System.Drawing.Point(85,50)
$CLock.Font                      	= 'Microsoft Sans Serif,28'
$CLock.ForeColor				= "#ff0000"

$label 								= New-Object System.Windows.Forms.Label
$label.Location				 	= New-Object System.Drawing.Point(60,0)
$label.Size 							= New-Object System.Drawing.Size(280,40)
$label.Font                      	= 'Microsoft Sans Serif,24'
#$label.Text 						= "Pomodoro"

$ticker 								= New-Object System.Windows.Forms.Label
$ticker.Location				 	= New-Object System.Drawing.Point(20,20)
$ticker.Size 						= New-Object System.Drawing.Size(280,40)
$ticker.Font                      	= 'Microsoft Sans Serif,24'
$ticker.text							= "a"

$pauseButton = New-Object System.Windows.Forms.Button
$pauseButton.Location = New-Object System.Drawing.Point(100,150)
$pauseButton.Size = New-Object System.Drawing.Size(75,23)
$pauseButton.Text = 'Pause'
$pauseButton.Add_Click({
	if($global:onlyonce -eq 1)
	{
		$wshell = New-Object -ComObject wscript.shell;
		$wshell.AppActivate('Pomodoro')
		$wshell.SendKeys('^{UP}')
		$global:once = 0
	}
	$global:Pause = -not $global:Pause
})

$global:WorkMin = 1500
$global:ShortBreakMin = 300
$global:LongBreakMin = 1500
$global:StartTimeMinute =  (Get-Date).ToString("mm")
$global:OldTimeSecond =  (Get-Date).ToString("ss")
$global:BeanCounter = 0
$global:Reps = 0
$global:Pause = 0
$global:once = 1
$global:oldwindow
$global:letterArray = 'a','b','c','d'

$mediaPlayer = New-Object system.windows.media.mediaplayer
$mediaPlayer.open('C:\Users\Mick\Documents\Projects\psPomodoro\timber.mp3')
$timer1 = New-Object 'System.Windows.Forms.Timer' 
$timer1_Tick={
		
		if ($global:BeanCounter -eq 0){
			$global:Reps++
			$mediaPlayer.open('C:\Users\Mick\Documents\Projects\psPomodoro\checkmark.wav')
			$mediaPlayer.Play()
			if ($global:Reps % 8 -eq 0){
				$global:BeanCounter = $global:LongBreakMin
				Write-Host "LongBreakMin"
				$label.Text = "Break"
				$label.Location	= New-Object System.Drawing.Point(80,0)
			}
			elseif ($global:Reps % 2 -eq 0){
				$global:BeanCounter = $global:ShortBreakMin
				Write-Host "ShortBreakMin"
				$label.Text = "Break" 
				$label.Location	= New-Object System.Drawing.Point(80,0)
			}
			else{
				$global:BeanCounter = $global:WorkMin
				Write-Host "Work"
				$label.Text = "Work" 
				$label.Location = New-Object System.Drawing.Point(90,0)
			}
		}
		$CurrentTimeSecond = (Get-Date).ToString("ss")
		if ($CurrentTimeSecond -ne  $global:OldTimeSecond){
			$global:BeanCounter = $global:BeanCounter - $global:Pause
			$global:OldTimeSecond = $CurrentTimeSecond
			
		}
		$CountMinutes  =  [Math]::floor($global:BeanCounter / 60)
		$CountSeconds = $global:BeanCounter % 60
		
		if ($CountSeconds -lt 10){
			$CountSeconds = "0$($CountSeconds)"
		}
		if ($CountMinutes -lt 10){
			$CountMinutes = "0$($CountMinutes)"
		}
		$Clock.text = "$($CountMinutes):$($CountSeconds)"
    } 
$timer1.Enabled = $True
$timer1.Interval = 10
$timer1.add_Tick($timer1_Tick) 	

$Form.controls.AddRange(@($CLock))
$Form.Controls.Add($label)
$form.Controls.Add($pauseButton)

$Form.showDialog()
$Form.Dispose()

