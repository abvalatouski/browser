@ echo off

rem Copyright © 2021 Aliaksei Valatouski <abvalatouski@gmail.com>
rem 
rem Permission is hereby granted, free of charge, to any person obtaining a copy
rem of this software and associated documentation files (the “Software”),
rem to deal in the Software without restriction, including without limitation
rem the rights to use, copy, modify, merge, publish, distribute, sublicense,
rem and/or sell copies of the Software, and to permit persons to whom
rem the Software is furnished to do so, subject to the following conditions:
rem 
rem The above copyright notice and this permission notice shall be included
rem in all copies or substantial portions of the Software.
rem 
rem THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS
rem OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
rem FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
rem THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
rem LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
rem FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
rem IN THE SOFTWARE.

:main (
    setlocal

    set command=%~f0
    shift
    
    set subcommand=%0
    shift
    if /i not "%subcommand%" == "path" (
        if /i not "%subcommand%" == "open" (
            if "%subcommand%" == "/?" (
                call :usage %command%
                endlocal
                exit /b
            ) else if "%subcommand%" == "" (
                echo No subcommand provided. 2>&1
            ) else (
                echo Unknown subcommand '%subcommand%'. 2>&1 
            )

            for %%c in ("%command%") do (
                echo See '%%~nc /?'. 2>&1
            )
            endlocal
            exit /b 1
        )
    )

    set drive=1
    set parentfolder=1
    set filename=1
    set extension=1
    
    set quiet=0
    set links=

:parsearg
    if "%0" == "/?" (
        call :usage %command% %subcommand%
        endlocal
        exit /b
    ) else if /i "%subcommand%" == "path" (
        if /i "%0" == "/d" (
            set drive=0
            shift
            goto :parsearg
        ) else if /i "%0" == "/p" (
            set parentfolder=0
            shift
            goto :parsearg
        ) else if /i "%0" == "/f" (
            set filename=0
            shift
            goto :parsearg
        ) else if /i "%0" == "/e" (
            set extension=0
            shift
            goto :parsearg
        ) else if not "%0" == "" (
            echo Unexpected argument '%0'. 2>&1
            echo See '%command% %subcommand% /?'. 2>&1
            endlocal
            exit /b 1
        )
    ) else if /i "%subcommand%" == "open" (
        if /i "%0" == "/q" (
            set quiet=1
            shift
            goto :parsearg
        ) else if not "%0" == "" (
            set links=%links% "%0"
            shift
            goto :parsearg
        )
    )

    call :%subcommand%
    endlocal
    exit /b
)

:usage (
    if "%~2" == "" (
        echo Working with the default browser.
        echo.
        echo Subcommands
        echo.
        echo     path    Print path to the default browser.
        echo             See '%~n1 path /?'.
        echo.
        echo     open    Open links in the separate window of the default
        echo             browser and print ID of the launched process.
        echo             See '%~n1 open /?'.
        echo.
        echo Source Code
        echo.
        echo     Written by Aliaksei Valatouski ^<abvalatouski@gmail.com^>.
        echo     The source code is licensed under the MIT License.
        echo.
        echo     See 'type %~f1'
        echo     or 'https://github.com/abvalatouski/browser'.
        echo.
        echo Notes
        echo.
        echo     Tested on Windows 10 with:
        echo     Chrome, Edge, Firefox, IE and Opera.
    ) else if /i "%~2" == "path" (
        echo Prints path to the default browser.
        echo.
        echo     %~n1 %~2 [/?] [/d] [/p] [/f] [/e]
        echo.
        echo Options
        echo.
        echo.    /?  Show this help message.
        echo         Other options will be ignored.
        echo.
        echo     /d  Disable drive letter printing.
        echo.
        echo     /p  Disable parent folder printing.
        echo.
        echo     /f  Disable filename printing.
        echo.
        echo     /e  Disable extension printing.
        echo.
        echo Example
        echo.
        echo     ^> rem On author's machine.
        echo     ^> %~n1 path /d /p /e
        echo     chrome
    ) else if /i "%~2" == "open" (
        echo Opens links in the separate window of the default browser
        echo and prints ID of the launched window process.
        echo.
        echo     %~n1 %~2 [/?] [/q]
        echo.
        echo Options
        echo.
        echo.    /?  Show this help message.
        echo         Other options will be ignored.
        echo.
        echo     /q  Disable process ID printing.
        echo.
        echo Example
        echo.
        echo     ^> %~n1 open www.google.com unicode-table.com
        echo     1337
    )

    exit /b
)

:path (
    setlocal

    call :getpath

    if "%drive%" == "1" (
        for %%p in ("%browserpath%") do (
            set /p="%%~dp" <nul
        )
    )

    if "%parentfolder%" == "1" (
        for %%p in ("%browserpath%") do (
            set /p="%%~pp" <nul
        )
    )

    if "%filename%" == "1" (
        for %%p in ("%browserpath%") do (
            set /p="%%~np" <nul
        )
    )

    if "%extension%" == "1" (
        for %%p in ("%browserpath%") do (
            set /p="%%~xp" <nul
        )
    )

    rem For visual consistency with other Windows utilities.
    echo.

    endlocal
    exit /b
)

:open (
    setlocal

    call :getpath

    rem `wmic prints empty line into `stderr`.
    for /f "tokens=3 delims=; " %%i in (
        'wmic process call Create "%browserpath%" 2^>nul ^| findstr "ProcessId"'
    ) do (
        if "%quiet%" == "0" (
            echo %%i
        )
    )

    rem Waiting the browser to startup.
    timeout 1 >nul

    for %%l in (%links%) do (
        "%browserpath%" "%%l"
    )

    endlocal
    exit /b
)

:getpath (
    set key=HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\Shell\Associations
    set key=%key%\UrlAssociations\http\UserChoice
    set lookup=reg query %key%
    for /f "tokens=3 delims= " %%i in ('%lookup% ^| findstr /i "ProgId"') do (
        set browserid=%%i
    )

    set key=HKEY_CLASSES_ROOT\%browserid%\Shell\Open\Command
    set lookup=reg query %key%
    for /f delims^=^"^ tokens^=2 %%b in ('%lookup% ^| findstr "REG_SZ"') do (
        set browserpath=%%b
    )

    exit /b
)
