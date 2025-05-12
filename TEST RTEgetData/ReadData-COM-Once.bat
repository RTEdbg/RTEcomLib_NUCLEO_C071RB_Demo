@echo off
REM Transfer data from the embedded system via a serial channel (COM port).
REM Modify the COM port name and parameters as needed.
"c:\RTEdbg\UTIL\RTEgetData\RTEgetData.exe" COM6=1500000 0 0 -decode=Decode.bat
