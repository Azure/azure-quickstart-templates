Function ShowDialog {


Add-Type -AssemblyName System.Windows.Forms
$Screen = [System.Windows.Forms.Screen]::PrimaryScreen
	$form1_Load = {
		$script:countdown = [timespan]'00:55:00' 
		$Text.Text = "YOUR CLOUD COMPUTER HAS BEEN ON FOR " ,$countdown.Minutes, " MINUTES " ,$countdown.Seconds, " SECONDS."
		$timer1.Start()
	}


	$timer1_Tick = {
        if ($script:countdown -ge [timespan]'00:59:59') {
        $timer1.Stop()
        $Form.Close()
        }
        Else{}
		$script:countdown += [timespan]'00:00:01'
		$Text.Text = "YOUR CLOUD COMPUTER HAS BEEN ON FOR " ,$countdown.Minutes, " MINUTES " ,$countdown.Seconds, " SECONDS."
	}

$SubMessage = "Stop your computer now if you don't want to pay another hour of game time."
$timer1 = New-Object System.Windows.Forms.Timer
$Form = New-Object system.Windows.Forms.Form
$Form.BackColor = "#25253f"
$form.AutoScale = 1
$Form.TopMost = $true
$Form.Width = $Screen.Bounds.Width
$Form.Height = 200
$Form.FormBorderStyle = '0'
$Form.StartPosition = 'Manual'
$Form.Top = 0
$form.AutoScale = 
$Form.Left = ($Screen.Bounds.Width - $Form.Width)/2
$form.add_Load($form1_Load)

$image = [System.Drawing.Image]::FromFile("$ENV:ProgramData\ParsecLoader\Parsec.png")
$pictureBox = new-object Windows.Forms.PictureBox
$pictureBox.Width = 100
$pictureBox.Height = 100
$picturebox.SizeMode = "StretchImage"
$pictureBox.Image = $image
$TextImage = $($($Form.Width - $Text.Width) / 10) * $(5.25 - 2)
$picturebox.location = New-Object System.Drawing.Point($TextImage,25)
$form.controls.add($pictureBox)
$Text = New-Object system.windows.Forms.Label
$Text.Text = '00:00:00'
$Text.TextAlign = 'MiddleLeft'
$Text.Height = 50
$Text.Width = $Screen.Bounds.Width / 4.25
$TextX = (($Form.Width - $Text.Width) / 10) * 5.25
$Text.Location = New-Object System.Drawing.Point($TextX,25)
$Text.Font = "Rubik,11,style=Bold"
$Text.ForeColor = "#CDCDCD"
$Form.controls.Add($Text)
$TextMessage = New-Object system.windows.Forms.Label
$TextMessage.Text = $SubMessage
$TextMessage.TextAlign = 'MiddleLeft'
$TextMessage.Height = 80
$TextMessage.Width = $Screen.Bounds.Width / 4.25
$TextXMessage = (($Form.Width - $Text.Width) / 10) * 6
$TextMessage.Location = New-Object System.Drawing.Point($TextX,50)
$TextMessage.Font = "Rubik,11"
$TextMessage.ForeColor = "#CDCDCD"
$timer1.Interval = 1000
$timer1.add_Tick($timer1_Tick)
$form.ResumeLayout()

$Form.controls.Add($TextMessage)

    $width = 200
    $okBtn = New-Object System.Windows.Forms.Button
    $okBtn.Text = 'Ignore'
    $okbtn.BackColor = "#7b84f7"
    $okBtn.Width = $width
    $okBtn.Height = 35
    $okBtn.FlatStyle = 'Flat'
    $okBtn.FlatAppearance.BorderColor = '#7b84f7'
    $okBtn.Font = "Microsoft Sans Serif,11,style=Bold"
    $okBtn.ForeColor = "#25253f"
    $okBtnX = ($Form.Width / 2) - $width - 25
    $okBtnY = $Form.Height - $okBtn.Height - 25
    $okBtn.Location = New-Object System.Drawing.Point($okBtnX,$okBtnY)
    $okBtn.Add_Click({
        $Form.Close()
    })
    $Form.Controls.Add($okBtn)
    $cancelBtn = New-Object System.Windows.Forms.Button
    $cancelBtn.Text = 'Remind me in 1 hour'
    $cancelbtn.BackColor = "#7b84f7"
    $cancelBtn.Width = 200
    $cancelBtn.Height = 35
    $cancelBtn.FlatStyle = 'Flat'
    $cancelBtn.FlatAppearance.BorderColor = '#7b84f7'
    $cancelBtn.Font = "Microsoft Sans Serif,11,style=Bold"
    $cancelBtn.ForeColor = "#25253f"
    $cancelBtnX = ($Form.Width / 2)
    $cancelBtnY = $Form.Height - $cancelBtn.Height - 25
    $cancelBtn.Location = New-Object System.Drawing.Point($cancelBtnX,$cancelBtnY)
    $cancelBtn.Add_Click({
    [int]3300 + ([int]3599 - [int]$script:countdown.TotalSeconds) | Out-File $env:programdata\ParsecLoader\Time.txt


Start-Process powershell.exe -ArgumentList "-windowstyle hidden -executionpolicy bypass -file $env:programdata\ParsecLoader\OneHour.ps1" 

$form.Close()

    })
    $Form.Controls.Add($cancelBtn)

[void]$Form.ShowDialog()

$Form.Dispose()

}
ShowDialog