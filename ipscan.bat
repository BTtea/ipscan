@echo off
setlocal EnableDelayedExpansion
if %1. equ . (
	echo.
	echo.	use : ipscan [ -on ^| -off ] [ -a [n.n.n.n] ^| -m [n.n.n] [start_number] [end_number] ]
	echo.
	echo.	You can replace n with * , and the range of * is 1~254.
	echo.
	echo.	Option : 
	echo.		-on     Computer showing online.
	echo.		-off    Computer showing offline.
	echo.		-a      Only one set of data.
	echo.		-m      Multiple data.
	echo.
	echo.	example : 
	echo.
	echo.		ipscan -a 192.168.1.1
	echo.
	echo.		ipscan -on -a 192.168.1.*
	echo.
	echo.		ipscan -off -m 192.168.1 1 5
	echo.
	echo.		ipscan -on -m 192.168.1 1 5 -off -m 192.168.1 6 10
	exit /b 0
)
set flag=0
:parmLoop
	if %1. equ . exit /b 0
	if "%1" equ "-on" (
	    set flag=0
	    shift /1
		goto parmLoop
	)
	if "%1" equ "-off" (
	    set flag=1
	    shift /1
		goto parmLoop
	)
	if "%1" equ "-a" (
		for /f "tokens=1-4 delims=." %%a in ("%2") do (
			if "%%d" equ "*" call :scan %%a.%%b.%%c 1 254 !flag!
			if "%%d" neq "*" call :scan %%a.%%b.%%c %%d %%d !flag!
		)
		for /l %%a in (1,1,2) do shift /1
		goto parmLoop
	)
	if "%1" equ "-m" (
		call :scan %2 %3 %4 !flag!
		for /l %%a in (1,1,4) do shift /1
		goto parmLoop
	)
if %1. neq . goto parmLoop
exit /b 0

:scan
	set num=%2
	if %4. equ 0. (set status=online) else set status=offline
	:main
		ping %1.%num% -n 1 -w 200>nul
		if %errorlevel% equ %4 echo.%1.%num% : !status!
		set /a num+=1
	if %num% leq %3 goto main
goto :eof
