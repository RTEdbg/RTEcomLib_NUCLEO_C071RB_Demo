@echo off
REM Take a snapshot of a running embedded system, run the RTEmsg application to decode the data.
REM and launch Notepad++ and CSV Viewer to view the decoded messages.

REM Read the documentation in the Readme file.

if not exist output md output

REM The command CD (change working directory) is only necessary if the batch file
REM  is started from a program like the Notepad++
REM cd "c:\RTEdbg\Demo\STM32L053\TEST"

if exist Data.bin del Data.bin

REM The command sequence is as follows:
REM   Read message filter
REM   Write zero to it (disable message logging)
REM   Delay by reading dummy data => allow the embedded system to write the unfinished messages (if any)
REM   Read logged binary data (g_rtedbg data structure containing header and circular buffer with data)
REM   Restore the filter value (restart message logging)
"c:\ST\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe" -c port=SWD mode=HOTPLUG shared -q --read 0x20000004 4 "Filter.bin" -fillmemory 0x20000004 size=4 pattern=0 --read 0x20000000 0x400 "Temp.bin" --read 0x20000000 0x2028 "Data.bin" --write "Filter.bin" 0x20000004
IF %ERRORLEVEL% NEQ 0 goto Error

REM Remove the temporary files
del Filter.bin
del Temp.bin

REM Decode the binary data file. The files will be created in the output folder.
Decode.bat

:Error
REM Pause to display error message in console window
pause
