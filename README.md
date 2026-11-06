# Powershell script for internal HDD power control via USB Relay Module 
USB Relay Module is based on CH340 chip (LCUS) <http://www.chinalctech.com/m/view.php?aid=131>.

HDD is installed in Hard Drive enclosure with power button.

USB Relay adapter closes power contact of HDD enclosure on 0xA0, 0x01, 0x01, 0xA2 command.

USB Relay adapter opens power contact of HDD enclosure on 0xA0, 0x01, 0x00, 0xA1 command.

LCUS-1 does not support Status command 0xFF.
