@echo off
:: =============================================
:: ClearClipboard_v3.bat
:: �ŶKï�M�z�u�� - �@��M�z�ŶKï�u��
:: �ݨD�G.NET Framework 4.0+ (�t4.8.1)
:: �v���G�ݭn�޲z���v������
:: =============================================

:: ��l�Ƥ�x
echo [%date% %time%] �}�l���� > "%temp%\ClipInstaller.log"
echo �t�ά[�c�G%PROCESSOR_ARCHITECTURE% >> "%temp%\ClipInstaller.log"

:: �ˬd�޲z���v��
fltmc >nul 2>&1 || (
    echo ���b�ШD�޲z���v��...
    echo �ЦbUAC���ܤ��I��"�O" >> "%temp%\ClipInstaller.log"
    powershell -Command "Start-Process -FilePath '%~dpnx0' -Verb RunAs" & exit
)

:: ===== �޲z���v���U���� =====
echo [���A] �{�b���޲z���v�� >> "%temp%\ClipInstaller.log"

:: �ˬd.NET Framework�sĶ��
set "csc="
for %%i in (
    "%windir%\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
    "%windir%\Microsoft.NET\Framework\v4.0.30319\csc.exe"
) do if exist "%%i" set "csc=%%i" & goto :compile

echo ���~�G�䤣�� .NET Framework 4.x �sĶ�� >> "%temp%\ClipInstaller.log"
echo �нT�{�w�w�� .NET Framework 4.0 �Χ󰪪���
pause
exit /b

:compile
echo �ϥνsĶ���G%csc% >> "%temp%\ClipInstaller.log"

:: �ͦ�C#��l�X - �ϥ���q�j�A��
(
    echo using System;
    echo using System.Windows.Forms;
    echo using System.Runtime.InteropServices;
    echo using System.Threading;
    echo class Program ^{
    echo     [STAThread]
    echo     static void Main^(^) ^{
    echo         try ^{
    echo             Clipboard.Clear^(^);
    echo         ^} catch ^(ExternalException^) ^{
    echo             Environment.Exit^(2^); 
    echo         ^} catch ^(ThreadStateException^) ^{
    echo             Environment.Exit^(3^);
    echo         ^} catch ^(Exception^) ^{
    echo             Environment.Exit^(1^);
    echo         ^}
    echo     ^}
    echo ^}
) > "%temp%\ClipboardClear_v3.cs"

:: �sĶ�{��
echo ���b�sĶ... >> "%temp%\ClipInstaller.log"
"%csc%" /nologo /target:winexe /out:"%temp%\ClipClear.exe" "%temp%\ClipboardClear_v3.cs" 2>> "%temp%\ClipInstaller.log"

if not exist "%temp%\ClipClear.exe" (
    echo �sĶ���ѡI�ˬd��x�G%temp%\ClipInstaller.log
    pause
    exit /b
)

:: �ƻs��t�Υؿ�
echo ���b�]�m�� System32... >> "%temp%\ClipInstaller.log"
copy /y "%temp%\ClipClear.exe" "%SystemRoot%\System32\" >nul 2>&1

if exist "%SystemRoot%\System32\ClipClear.exe" (
    set "exePath=%SystemRoot%\System32\ClipClear.exe"
    echo ���\�g�J�t�Υؿ� >> "%temp%\ClipInstaller.log"
) else (
    echo ĵ�i�G�L�k�g�JSystem32�A��β{�b�ؿ� >> "%temp%\ClipInstaller.log"
    copy /y "%temp%\ClipClear.exe" "%~dp0ClipClear.exe" >nul
    set "exePath=%~dp0ClipClear.exe"
)

:: ===== ���U�k��ﶵ =====
echo ���b���U�k��ﶵ... >> "%temp%\ClipInstaller.log"

:: �ɮץk��ﶵ
reg add "HKCR\*\shell\ClearClipboard" /ve /d "�@��M�z�ŶKï" /f >nul || (
    echo ���~�G�L�k�g�JHKCR\*\shell >> "%temp%\ClipInstaller.log"
    goto :error
)
reg add "HKCR\*\shell\ClearClipboard" /v "Icon" /d "%exePath%,0" /f >nul
reg add "HKCR\*\shell\ClearClipboard\command" /ve /d "\"%exePath%\"" /f >nul

:: �ୱ/��Ƨ��I���k��ﶵ
reg add "HKCR\Directory\Background\shell\ClearClipboard" /ve /d "�@��M�z�ŶKï" /f >nul || (
    echo ���~�G�L�k�g�JDirectory\Background >> "%temp%\ClipInstaller.log"
    goto :error
)
reg add "HKCR\Directory\Background\shell\ClearClipboard" /v "Icon" /d "%exePath%,0" /f >nul
reg add "HKCR\Directory\Background\shell\ClearClipboard\command" /ve /d "\"%exePath%\"" /f >nul

:: ����
echo �w�˦��\�I >> "%temp%\ClipInstaller.log"
echo �Цb�ɮשήୱ�W�k��ݨ�"�@��M�z�ŶKï"�\��
pause
exit /b

:error
echo �w�˹L�{���o�Ϳ��~�A���ˬd��x�G%temp%\ClipInstaller.log
pause