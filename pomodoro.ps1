using namespace System.Drawing
using namespace System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)

$code = @"
    [System.Runtime.InteropServices.DllImport("Shcore.dll")]
    public static extern int SetProcessDpiAwareness(int dpiAwarenessMode);
"@
$PInvoke = Add-Type -MemberDefinition $code -Name "PInvoke" -PassThru
$null = $PInvoke::SetProcessDpiAwareness(2)
Add-Type -AssemblyName PresentationCore 
$Form = New-Object system.Windows.Forms.Form
$Form.ClientSize = '230,175'
$Form.text = "Pomodoro"
$Form.BackColor = "#f7f5dd"
$Form.TopMost = $false
$Form.StartPosition = [FormStartPosition]::CenterScreen;

$CLock = New-Object system.Windows.Forms.Label
$CLock.text = "The time is?"
$CLock.BackColor = "#f7f5dd"
$CLock.AutoSize = $true
$CLock.width = 25
$CLock.height = 10
$CLock.location = New-Object System.Drawing.Point(55,50)
$CLock.Font = 'Overpass,28'
$CLock.ForeColor = "#ff0000"

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(60,0)
$label.Size = New-Object System.Drawing.Size(280,40)
$label.ForeColor="000000"
$label.Font = 'Segoe UI,24'

$ticker = New-Object System.Windows.Forms.Label
$ticker.Location = New-Object System.Drawing.Point(90,100)
$ticker.Size = New-Object System.Drawing.Size(280,40)
$ticker.Font = [Font]::new("Segoe UI", 24)
$ticker.ForeColor="000000"
$ticker.text = ""

$pauseButton = New-Object System.Windows.Forms.Button
$pauseButton.Location = New-Object System.Drawing.Point(75,150)
$pauseButton.Size = New-Object System.Drawing.Size(75,23)
$pauseButton.Text = 'Pause'
$pauseButton.Add_Click({
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
$global:letterArray = '0x000025F5', '0x000025F6', '0x000025F7', '0x000025F4'

if (Test-Path config.json)
{
	$json = Get-Content config.json | ConvertFrom-Json
	$Form.text = $json.program_title
	$Form.BackColor = $json.backcolor
	$CLock.BackColor = $json.backcolor
	$CLock.ForeColor = $json.clock_forecolor
	$CLock.Font = $json.clockfont
	$label.ForeColor = $json.label_forecolor 
	$label.Font = $json.tickerfont
	$global:WorkMin = $json.worktimes.workmin
	$global:ShortBreakMin = $json.worktimes.shortbreakmin
	$global:LongBreakMin = $json.worktimes.longbreakmin
	$ticker.ForeColor = $json.ticker_forecolor
	$global:letterArray = $json.ticker_letters.letter_one, $json.ticker_letters.letter_two,$json.ticker_letters.letter_three, $json.ticker_letters.letter_four
}

$mediaPlayer = New-Object system.windows.media.mediaplayer
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
				$label.Location	= New-Object System.Drawing.Point(60,0)
			}
			elseif ($global:Reps % 2 -eq 0){
				$global:BeanCounter = $global:ShortBreakMin
				Write-Host "ShortBreakMin"
				$label.Text = "Break" 
				$label.Location	= New-Object System.Drawing.Point(60,0)
			}
			else{
				$global:BeanCounter = $global:WorkMin
				Write-Host "Work"
				$label.Text = "Work" 
				$label.Location = New-Object System.Drawing.Point(60,0)
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
		$tickeroutput = $global:BeanCounter % 4
		$ticker.text = [char]::ConvertFromUtf32(($global:letterArray[$tickeroutput]))
		$Clock.text = "$($CountMinutes):$($CountSeconds)"
    } 
$timer1.Enabled = $True
$timer1.Interval = 25
$timer1.add_Tick($timer1_Tick) 	

$Form.controls.AddRange(@($CLock))
$Form.Controls.Add($label)
$Form.Controls.Add($ticker)
$form.Controls.Add($pauseButton)

#Pulls focus to window
$wshell = New-Object -ComObject wscript.shell;
$wshell.AppActivate($Form.text);

$Form.showDialog()
$Form.Dispose()

