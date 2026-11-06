# https://www.aggsoft.com/serial-port-monitor/how-to-check-com-port-in-windows.htm
# [System.IO.Ports.SerialPort]::getportnames() 
# Get-PnpDevice -FriendlyName '*COM*' | Select-Object FriendlyName,InstanceId
# $SerialPort=New-Object System.IO.Ports.SerialPort 'COM3',9600,'None',8,one;
# $SerialPort.Open();
# $SerialPort.WriteLine('hello');
# Start-Sleep -Milliseconds 200;
# $resp = $SerialPort.ReadExisting();
# $SerialPort.Close();
# $resp
# A0 01 01 A2 open relay, A0 01 00 A1 close relay (attention: commands' format must be hex)

# Procedure to detect USB-COM assignment
$MyPort = (Get-PnpDevice -Class Ports -PresentOnly -FriendlyName "USB-SERIAL*").Name
$DefaultComPort = "COM5"
$ComPort = $MyPort.Substring($MyPort.IndexOf("COM"), $DefaultComPort.Length)
#
# Write-Host "Relay connected to $ComPort"
# LCOS commands
[Byte[]] $PowerOn = 0xA0, 0x01, 0x01, 0xA2
[Byte[]] $PowerOff = 0xA0, 0x01, 0x00, 0xA1
# Init dialog
$Title = "Command to control HDD via $ComPort"
$Prompt = "Select your command:"
$Choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&Up", "&Down", "&Cancel")
$Default = 2

# Prompt for the choice
$Choice = $host.UI.PromptForChoice($Title, $Prompt, $Choices, $Default)

# Action based on the choice
switch($Choice)
{
    0 { Write-Host "Power up HDD"
        $Buffer = $PowerOn
        }
    1 { Write-Host "Power down HDD"
        $Buffer = $PowerOff
        }
    2 { Write-Host "Cancel and quit"
        exit
        }
}
$SerialPort=New-Object System.IO.Ports.SerialPort $ComPort, 9600, 'None', 8, one
$SerialPort.Open()
Start-Sleep -Milliseconds 250
$SerialPort.Write($Buffer, 0, $Buffer.Count)
$SerialPort.Close()
Write-Host "Done!"
Start-Sleep -Seconds 3