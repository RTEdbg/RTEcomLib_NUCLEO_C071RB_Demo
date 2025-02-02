@echo off
REM Transfer data from embedded system using ST-Link Debug Probe GDB Server
REM RTEgdbData is started in persistent mode (-p) to allow multiple data
REM transfers from the embedded system to the host. Since the parameter
REM  -decode=batch_file is defined, the decoding and display of the data
REM starts automatically after the data transfer.

"c:\RTEdbg\UTIL\RTEgdbData\RTEgdbData.exe" 61234 0x20000000 0 -p -decode=Decode.bat -priority -driver=stlinkserver.exe -driver="ST-LINK_gdbserver.exe"
IF %ERRORLEVEL% EQU 0 goto End
pause
:End