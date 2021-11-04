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
            if /i not "%subcommand%" == "name" (
                if "%subcommand%" == "/?" (
                    call :usage %command%
                    endlocal
                    exit /b
                ) else if "%subcommand%" == "" (
                    echo No subcommand provided. >&2
                ) else (
                    echo Unknown subcommand '%subcommand%'. >&2 
                )

                for %%c in ("%command%") do (
                    echo See '%%~nc /?'. >&2
                )

                endlocal
                exit /b 1
            )
        )
    )

    set drive=1
    set parentfolder=1
    set filename=1
    set extension=1
    
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
            echo Unexpected argument '%0'. >&2
            echo See '%command% %subcommand% /?'. >&2
            endlocal
            exit /b 1
        )
    ) else if /i "%subcommand%" == "open" (
        if not "%0" == "" (
            set links=%links% %0
            shift
            goto :parsearg
        )
    ) else if /i "%subcommand%" == "name" (
        if not "%0" == "" (
            echo Unexpected argument '%0'. >&2
            echo See '%command% %subcommand% /?'. >&2
            endlocal
            exit /b 1
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
        echo     name    Print name of the default browser.
        echo             See '%~n1 name /?'.
        echo.
        echo     open    Open links in the separate window of the default
        echo             browser.
        echo             See '%~n1 open /?'.
        echo.
        echo     path    Print path to the default browser.
        echo             See '%~n1 path /?'.
        echo.
        echo Supported Browsers
        echo.
        echo     Brave, Chrome, Edge, Firefox, IE, Opera.
        echo.
        echo Source Code
        echo.
        echo     Written by Aliaksei Valatouski ^<abvalatouski@gmail.com^>.
        echo     The source code is licensed under the MIT License.
        echo.
        echo     See 'type %~f1'
        echo     or 'https://github.com/abvalatouski/browser'.
    ) else if /i "%~2" == "path" (
        echo Prints path to the default browser.
        echo.
        echo     %~n1 %~2 [/?] [/d] [/e] [/f] [/p]
        echo.
        echo Options
        echo.
        echo.    /?  Show this help message.
        echo         Other options will be ignored.
        echo.
        echo     /d  Disable drive letter printing.
        echo.
        echo     /e  Disable extension printing.
        echo.
        echo     /f  Disable filename printing.
        echo.
        echo     /p  Disable parent folder printing.
        echo.
        echo Example
        echo.
        echo     ^> rem On author's machine.
        echo     ^> %~n1 path /d /e /p
        echo     chrome
    ) else if /i "%~2" == "open" (
        echo Opens links in the separate window of the default browser.
        echo.
        echo     %~n1 %~2 [/?] {url}
        echo.
        echo Options
        echo.
        echo.    /?  Show this help message.
        echo.
        echo Example
        echo.
        echo     ^> %~n1 open www.google.com unicode-table.com
    ) else if "%~2" == "name" (
        echo Prints name of the default browser.
        echo.
        echo     %~n1 %~2 [/?]
        echo.
        echo Options
        echo.
        echo.    /?  Show this help message.
        echo.
        echo Example
        echo.
        echo     ^> rem On author's machine.
        echo     ^> %~n1 name
        echo     Chrome
    )

    exit /b
)

:path (
    setlocal

    call :getpath
    call :getname

    if not "%errorlevel%" == "0" (
        echo Unsupported browser. >&2
    )

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
    call :getname

    if not "%errorlevel%" == "0" (
        call :unsupported
        exit /b 1
    )

    for %%p in ("%browserpath%") do (
        if "%browsername%" == "Brave" (
            start /d "%%~dp%%~pp" %%~np%%~xp --new-window %links%
        ) else if "%browsername%" == "Chrome" (
            start /d "%%~dp%%~pp" %%~np%%~xp --new-window %links%
        ) else if "%browsername%" == "Edge" (
            echo Not implemented. >&2
            exit /b 1
        ) else if "%browsername%" == "Firefox" (
            start /d "%%~dp%%~pp" %%~np%%~xp %links%
        ) else if "%browsername%" == "IE" (
            echo Not implemented. >&2
            exit /b 1
        ) else if "%browsername%" == "Opera" (
            start /d "%%~dp%%~pp" %%~np%%~xp --new-window %links%
        )
    )

    endlocal
    exit /b
)

:name (
    setlocal

    call :getpath
    call :getname

    if "%errorlevel%" == "0" (
        echo %browsername%
    ) else (
        call :unsupported
        endlocal
        exit /b 1
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

:getname (
    echo "%browserpath%" | findstr /i "Brave" >nul
    if "%errorlevel%" == "0" (
        set browsername=Brave
        exit /b
    )

    echo "%browserpath%" | findstr /i "Chrome" >nul
    if "%errorlevel%" == "0" (
        set browsername=Chrome
        exit /b
    )

    echo "%browserpath%" | findstr /i "Edge" >nul
    if "%errorlevel%" == "0" (
        set browsername=Edge
        exit /b
    )

    echo "%browserpath%" | findstr /i "Firefox" >nul
    if "%errorlevel%" == "0" (
        set browsername=Firefox
        exit /b
    )

    echo "%browserpath%" | findstr /i "Internet Explorer" >nul
    if "%errorlevel%" == "0" (
        set browsername=IE
        exit /b
    )

    echo "%browserpath%" | findstr /i "Opera" >nul
    if "%errorlevel%" == "0" (
        set browsername=Opera
        exit /b
    )

    exit /b 1
)

:unsupported (
    echo Unsupported browser. >&2
    echo Try 'browser path 2^>nul' to see what's installed on your machine. >&2
    echo Type 'browser /?' to see the list of supported browsers. >&2

    exit /b
)
