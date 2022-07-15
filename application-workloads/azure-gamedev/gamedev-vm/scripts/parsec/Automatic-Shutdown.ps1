Add-Type @'
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace PInvoke.Win32 {

    public static class UserInput {

        [DllImport("user32.dll", SetLastError=false)]
        private static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

        [StructLayout(LayoutKind.Sequential)]
        private struct LASTINPUTINFO {
            public uint cbSize;
            public int dwTime;
        }

        public static DateTime LastInput {
            get {
                DateTime bootTime = DateTime.UtcNow.AddMilliseconds(-Environment.TickCount);
                DateTime lastInput = bootTime.AddMilliseconds(LastInputTicks);
                return lastInput;
            }
        }

        public static TimeSpan IdleTime {
            get {
                return DateTime.UtcNow.Subtract(LastInput);
            }
        }

        public static int LastInputTicks {
            get {
                LASTINPUTINFO lii = new LASTINPUTINFO();
                lii.cbSize = (uint)Marshal.SizeOf(typeof(LASTINPUTINFO));
                GetLastInputInfo(ref lii);
                return lii.dwTime;
            }
        }
    }
}
'@
function AutomaticShutdown {
	
	Add-Type -AssemblyName System.Windows.Forms

	[System.Windows.Forms.Application]::EnableVisualStyles()
	$form1 = New-Object System.Windows.Forms.Form
	$label000000 = New-Object System.Windows.Forms.Label
	$timer1 = New-Object System.Windows.Forms.Timer
    $button = New-Object System.Windows.Forms.Button
	$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState



	$form1_Load = {
		$script:countdown = [timespan]'00:10:00' # 10 minutes
		$label000000.Text = "$countdown"
		$timer1.Start()

	}
	
    $button_logic = {
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -windowstyle hidden -file $ENV:ProgramData\Automatic-Shutdown.ps1"
    $form1.Close()
    }

	$timer1_Tick = {
        if ($countdown -lt [timespan]'00:00:02') {$timer1.Stop()
        Stop-Computer
        }
        Else{}
		$script:countdown -= [timespan]'00:00:01'
		$label000000.Text = "$countdown"

	}
	
	$Form_StateCorrection_Load =
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$form1.WindowState = $InitialFormWindowState
	}


	$form1.SuspendLayout()
    $form1.BringToFront()
    $Form1.ControlBox = $False
	$form1.Controls.Add($label000000)
	$form1.AutoScaleDimensions = '8, 17'
	$form1.AutoScaleMode = 'Font'
	$form1.BackColor = 'ActiveCaption'
	$form1.ClientSize = '400, 200'
	$form1.FormBorderStyle = 'Fixed3D'
	$form1.Name = 'form1'
	$form1.StartPosition = 'CenterScreen'
	$form1.Text = 'Automatic Shutdown On Idle'
	$form1.add_Load($form1_Load)

    $Button.Location = New-Object System.Drawing.Size(75,75)
    $Button.Size = New-Object System.Drawing.Size(150,23)
    $Button.Text = "Cancel Shutdown"
    $button.Add_click($button_logic)


	$label000000.AutoSize = $True
	$label000000.Font = 'Lucida Fax, 24pt, style=Bold'
	$label000000.Location = '90, 25'
	$label000000.Margin = '4, 0, 4, 0'
	$label000000.Name = 'label000000'
	$label000000.Size = '200, 46'
	$label000000.TabIndex = 0
	$label000000.Text = '00:00:00'

	$timer1.Interval = 1000
	$timer1.add_Tick($timer1_Tick)
	$form1.ResumeLayout()

	$InitialFormWindowState = $form1.WindowState
	$form1.add_Load($Form_StateCorrection_Load)
    $Form1.Controls.Add($Button)
	return $form1.ShowDialog()
}

function idle {
$readfile = (Get-Content -Path $env:ProgramData\Autoshutdown.txt) - 10
do {
[PInvoke.Win32.UserInput]::LastInput | Out-Null
[PInvoke.Win32.UserInput]::IdleTime | Out-Null
Start-Sleep -Seconds 1
}
Until([PInvoke.Win32.UserInput]::Idletime.TotalMinutes -gt $readfile)
AutomaticShutdown
}

idle