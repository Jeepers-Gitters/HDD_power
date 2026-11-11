#
# A0 01 01 A2 open relay, A0 01 00 A1 close relay (attention: commands' format must be hex)
 param (
    [Parameter()]
    [string]$batch
 )
#
# LCOS commands
#
[Byte[]] $PowerOn = 0xA0, 0x01, 0x01, 0xA2
[Byte[]] $PowerOff = 0xA0, 0x01, 0x00, 0xA1
[Byte[]] $RelayStatus = 0xFF
#
# Errors
#
$ScriptSuccess = 0
$NoPortsFound = 1
$UserQuit = 2
#
# Serial Port Settings
#
# ComPort Number, Baudrate, Parity, Bits, Stopbit
# $ComPortParams = "9600, 'None', 8, one"
#
# $DebugPreference = "Continue"
#
# 
function Write-ComPort {
    param (
      $Port,
      $Action
      )
  # We init parameters in this function to decrease a number of parameters
  $SerialPort = New-Object System.IO.Ports.SerialPort $Port, 9600, 'None', 8, one
  #
  # No check for open success as script exits in case of problem with chosen COM port
  #
  $SerialPort.Open()
  [string]$CheckPortInit = $SerialPort.BaudRate, $SerialPort.DataBits, $SerialPort.Parity, $SerialPort.StopBits
  Write-Debug "Port $Port settings:$CheckPortInit"
  $SerialPort.Write($Action, 0, $Action.Count)
  $CommandSent = [System.BitConverter]::ToString($Action)
  Write-Debug "Command $CommandSent sent to $Port"
  $SerialPort.Close()
  Write-Debug "$Port closed."
  }
#
# Procedure to detect USB-COM assignment
# 
$CommPorts=[string[]]@([System.IO.Ports.SerialPort]::getportnames())
$CommPortsNumber = $CommPorts.Count
if ( $CommPortsNumber -eq 0 ) {
  Write-Host "No COM ports found. Exiting"
  exit $NoPortsFound
  }
Write-Debug "$CommPortsNumber COM ports detected: $CommPorts" 
#
# Friendly name returned looks like this:
# USB-SERIAL CH340 (COM5)
#
$RelayPort = (Get-PnpDevice -Class Ports -PresentOnly -FriendlyName "USB-SERIAL*").Name
#
# We need to get a text between brackets
# This is a regex to detect such text
#
$SearchPattern = '(?<=\().+?(?=\))'
$ComPort = [regex]::Matches($RelayPort, $SearchPattern).Value
#
Write-Debug "Relay connected to $ComPort"
# Check which mode to run - if no $batch then it's menu mode
# if $batch && Up - PowerOn
# if $batch && Down - PowerOff
# $PSBoundParameters 
if ( $batch ) {
    if ( $batch -eq "Up" ) {
         Write-Debug "Powering HDD in batch mode."
         Write-ComPort -Port $ComPort -Action $PowerOn
         exit $ScriptSuccess
    } elseif ( $batch -eq "Down" ) { Write-Host "Not implemented mode $batch, entering menu mode." }
        else { Write-Host "Wrong parameters supplied, entering menu mode." }
} else { Write-Host "No parameters supplied, entering menu mode." }
#
# Init dialog
#
$MenuTitle = "Command to control HDD power via $ComPort"
$MenuPrompt = "Your choice:"
$PowerUp = New-Object System.Management.Automation.Host.ChoiceDescription '&Up', 'Switch on HDD power'
$PowerDown = New-Object System.Management.Automation.Host.ChoiceDescription '&Down', 'Switch off HDD power'
$QuitMenu = New-Object System.Management.Automation.Host.ChoiceDescription '&Cancel', 'Cancel and Quit'
$MenuChoices = [System.Management.Automation.Host.ChoiceDescription[]] @($PowerUp, $PowerDown, $QuitMenu)
$MenuDefault = 2
#
# Prompt for the choice
#
$UserChoice = $host.UI.PromptForChoice($MenuTitle, $MenuPrompt, $MenuChoices, $MenuDefault)
#
# Action based on the choice
#
switch($UserChoice)
{
    0 { Write-Host "Power up HDD"
        $Action = $PowerOn
        }
    1 { Write-Host "Power down HDD"
        $Action = $PowerOff
        }
    2 { Write-Host "Cancel and quit"
        exit $UserQuit
        }
}

Write-ComPort -Port $ComPort -Action $Action
Write-Host "Done!"
Start-Sleep -Seconds 3
exit $ScriptSuccess