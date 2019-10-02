@echo off
setlocal EnableDelayedExpansion
if %1. equ . (
	echo.
	echo.	use : ipscan [ -on ^| -off ^| -all ] [ -o [path] ]
	echo.		  [ -a [n.n.n.n] ^| -m [n.n.n] [start_number] [end_number] ]
	echo.
	echo.	You can replace n with * , and the number which is in range from 1 to 254.
	echo.
	echo.	Option : 
	echo.		-on     Computer showing online.
	echo.		-off    Computer showing offline.
	echo.		-all	Computer showing online and offline.
	echo.		-a      Only one set of data.
	echo.		-m      Multiple data.
	echo.		-o      Output the result to the file.
	echo.
	echo.	example : 
	echo.
	echo.		ipscan -a 192.168.1.1
	echo.
	echo.		ipscan -on -a 192.168.1.*
	echo.
	echo.		ipscan -off -m 192.168.1 1 5
	echo.
	echo.		ipscan -all -m 192.168.1 1 5
	echo.
	echo.		ipscan -on -m 192.168.1 1 5 -off -m 192.168.1 6 10
	echo.
	echo.		ipscan -o "C:\output.txt" -on -a 192.168.1.*
	exit /b 0
)
set flag=0
set output=
:parmLoop
	if "%1" equ "-on" (
	    set flag=0
	    shift /1
		goto parmLoop
	) else if "%1" equ "-off" (
	    set flag=1
	    shift /1
		goto parmLoop
	) else if "%1" equ "-all" (
		set flag=2
	    shift /1
		goto parmLoop
	) else if "%1" equ "-a" (
		for /f "tokens=1-4 delims=." %%a in ("%2") do (
			if "%%d" equ "*" call :scan %%a.%%b.%%c 1 254 !flag! !output! !filename!
			if "%%d" neq "*" call :scan %%a.%%b.%%c %%d %%d !flag! !output! !filename!
		)
		set output=
		for /l %%a in (1,1,2) do shift /1
		goto parmLoop
	) else if "%1" equ "-m" (
		call :scan %2 %3 %4 !flag! !output! !filename!
		set output=
		for /l %%a in (1,1,4) do shift /1
		goto parmLoop
	) else if "%1" equ "-o" (
		set output=1
		set filename=%2
	    for /l %%a in (1,1,2) do shift /1
		goto parmLoop
	)
if %1. neq . goto parmLoop
exit /b 0

:scan
	set num=%2
	set all=rem
	set not_all=rem
	set def=%5
	if defined def (set def=) else set def=rem
	if %4. equ 2. (set not_all=) else set all=
	%all% if %4. equ 0. (set status=online) else set status=offline
	:main
		ping %1.%num% -n 1 -w 200>nul
		%not_all% if %errorlevel% equ 0 (
		%not_all%		echo.%1.!num! : online
		%def% %not_all%	echo.%1.!num! : online>>%~6
		%not_all% ) else (
		%not_all%		echo.%1.!num! : offline
		%def% %not_all%	echo.%1.!num! : offline>>%~6
		%not_all% )
		%all% if %errorlevel% equ %4 (
		%all% 		echo.%1.!num! : !status!
		%def% %all% echo.%1.!num! : !status!>>%~6
		%all% )
		set /a num+=1
	if %num% leq %3 goto main
goto :eof
