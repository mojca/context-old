@ECHO OFF

REM author: Hans Hagen - PRAGMA ADE - Hasselt NL - www.pragma-ade.com

:userpath

if "%SETUPTEX%"=="done" goto done

if "%~s1"=="" goto selftest

set TEXMFOS=%~s1texmf-mswin
if exist %TEXMFOS%\bin\mtxrun.exe goto start

set TEXMFOS=%~s1\texmf-mswin
if exist %TEXMFOS%\bin\mtxrun.exe goto start

:selftest

set TEXMFOS=%~d0%~p0texmf-mswin
if exist %TEXMFOS%\bin\mtxrun.exe goto start

set TEXMFOS=%~d0%~p0\texmf-mswin
if exist %TEXMFOS%\bin\mtxrun.exe goto start

:start

set PATH=%TEXMFOS%\bin;%PATH%

:register

set SETUPTEX=done
set CTXMINIMAL=yes

:done
