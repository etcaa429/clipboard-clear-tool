@echo off
setlocal enabledelayedexpansion

:: =============================================
:: ClearClipboard_v0.3_Signed.bat
:: �ŶKï�M�z�u�� - �@��M�z�ŶKï�u�� (�t�j���R�W�P��ñ����ñ�p)
:: �ݨD�G.NET Framework 4.0+ (�t4.8.1), Windows SDK (�tsigntool.exe, sn.exe)
:: �v���G�ݭn�޲z���v������
:: =============================================

:: ��l�Ƥ�x
echo [%date% %time%] �}�l���� ClearClipboard_v3_Signed.bat > "%temp%\ClipInstaller.log"
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
) do if exist "%%i" set "csc=%%i" & goto :check_tools

echo ���~�G�䤣�� .NET Framework 4.x �sĶ�� >> "%temp%\ClipInstaller.log"
echo �нT�{�w�w�� .NET Framework 4.0 �Χ󰪪����C
pause
exit /b

:check_tools
echo �ϥνsĶ���G%csc% >> "%temp%\ClipInstaller.log"

:: �M�� signtool.exe �M sn.exe (�Ӧ� Windows SDK)
:: �`�N�G�o�Ǹ��|�i��]�z�� Windows SDK �����M�w�ˤ覡�Ӳ��C
:: �p�G�䤣��A�Ф�ʫ��w�䧹����|�νT�O��b PATH �����ܼƤ��C
set "SIGNTOOL="
set "SN_TOOL="

for /f "delims=" %%i in ('where /q signtool.exe 2^>nul ^&^& for %%j in (signtool.exe) do @echo %%~dp$PATH:j') do set "SIGNTOOL=%%i"
for /f "delims=" %%i in ('where /q sn.exe 2^>nul ^&^& for %%j in (sn.exe) do @echo %%~dp$PATH:j') do set "SN_TOOL=%%i"

if not defined SIGNTOOL (
    echo ���~�G�䤣�� signtool.exe�C�нT�{�w�w�� Windows SDK �Ϋ��w����|�C >> "%temp%\ClipInstaller.log"
    echo (�Ҧp�GC:\Program Files (x86)\Windows Kits\10\bin\10.0.xxxxx.0\x64\signtool.exe)
    pause
    exit /b
)
if not defined SN_TOOL (
    echo ĵ�i�G�䤣�� sn.exe�C�N���L�j���R�W�ˬd�C >> "%temp%\ClipInstaller.log"
    echo (�Ҧp�GC:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools\sn.exe)
    set "SKIP_SN=true"
)

echo �ϥ� signtool.exe: %SIGNTOOL% >> "%temp%\ClipInstaller.log"
if not defined SKIP_SN echo �ϥ� sn.exe: %SN_TOOL% >> "%temp%\ClipInstaller.log"

:: C# ���Ҭ����ܼ�
set "CERT_NAME=MyClearClipboardCert"

:: ====== �K�X��J�P�j�׵����y�{ ======
:get_password
cls
echo.
echo ====================================================
echo �Ь���ñ���ҳ]�w�K�X (�Ω�O�@�p�_)
echo ----------------------------------------------------
echo �K�X��ĳ�G
echo - �ܤ�8�Ӧr��
echo - �]�t�j�p�g�r���B�Ʀr�ίS��Ÿ�
echo - �קK�ϥέӤH��T�α`�γ�r
echo ====================================================
echo.

set "PFX_PASSWORD_PROMPT_DONE="

:prompt_password
if defined PFX_PASSWORD_PROMPT_DONE (
    echo �Э��s��J�K�X�C
)

:: �ϥ� PowerShell Ū�����ñK�X
for /f "usebackq" %%i in (`powershell -Command "$p = Read-Host -Prompt '��J�K�X' -AsSecureString; $p | ConvertFrom-SecureString"`) do set "PFX_PASSWORD_HASH=%%i"
for /f "usebackq" %%i in (`powershell -Command "$p = Read-Host -Prompt '�A����J�K�X�T�{' -AsSecureString; $p | ConvertFrom-SecureString"`) do set "PFX_PASSWORD_CONFIRM_HASH=%%i"

:: �N�w���r�ꪺ���ƭȤ���A�P�_�K�X�O�_�@�P
if not "!PFX_PASSWORD_HASH!"=="!PFX_PASSWORD_CONFIRM_HASH!" (
    echo [!] �⦸��J���K�X���@�P�A�Э��աC
    set "PFX_PASSWORD_PROMPT_DONE=true"
    goto :prompt_password
)

:: �������K�X�]�Ω�j�׵����A�Ъ`�N���B�K�X�|�u�ȥX�{�b�O���餤�A�����|�g�J�ϺС^
for /f "usebackq" %%i in (`powershell -Command "$p = [Runtime.InteropServices.Marshal]::SecureStringToBSTR((Convertto-SecureString -String '%PFX_PASSWORD_HASH%' -AsPlainText -Force)); try { [Runtime.InteropServices.Marshal]::PtrToStringBSTR($p) } finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($p) }"`) do set "PFX_PASSWORD_PLAIN=%%i"

if "!PFX_PASSWORD_PLAIN!"=="" (
    echo [!] �K�X���ର�šA�Э��s��J�C
    set "PFX_PASSWORD_PROMPT_DONE=true"
    goto :prompt_password
)

:: �K�X�j�׵��� (�ϥ� PowerShell ²��P�_)
echo �����K�X�j��...
powershell -NoProfile -Command ^
    "$password = '%PFX_PASSWORD_PLAIN%'; ^
    $score = 0; ^
    if ($password.Length -ge 8) { $score++ }; ^
    if ($password -match '[a-z]') { $score++ }; ^
    if ($password -match '[A-Z]') { $score++ }; ^
    if ($password -match '\d') { $score++ }; ^
    if ($password -match '[!@#$%^&*()_+\-=\[\]{};'':\"\\|,.<>\/?~`]') { $score++ }; ^
    if ($password.Length -ge 12) { $score++ }; ^
    if ($score -ge 5) { Write-Host '�K�X�j��: �j (�D�`����)' -ForegroundColor Green } ^
    else if ($score -ge 3) { Write-Host '�K�X�j��: �� (��ĳ�[�j)' -ForegroundColor Yellow } ^
    else { Write-Host '�K�X�j��: �z (�D�`������)' -ForegroundColor Red }; ^
    if ($score -lt 3) { exit 1 } else { exit 0 }"

if %errorlevel% neq 0 (
    echo [!] �K�X�j�׹L�z�A�Э��s�]�w�@�ӧ�j���K�X�C
    set "PFX_PASSWORD_PROMPT_DONE=true"
    goto :prompt_password
)

echo �K�X�w�]�w�C >> "%temp%\ClipInstaller.log"
REM �M������K�X�ܼ�
set "PFX_PASSWORD_PLAIN="

:: ====== �K�X��J�P�j�׵����y�{���� ======

:: �ͦ�C#��l�X - �ϥ���q�j�A��
(
    echo using System;
    echo using System.Windows.Forms;
    echo using System.Runtime.InteropServices;
    echo using System.Threading;
    echo using System.Reflection;
    echo [assembly: AssemblyVersion("0.1.0.0")]
    echo [assembly: AssemblyFileVersion("0.1.0.0")]
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

:: �j���R�W�ˬd (�i��)
if not defined SKIP_SN (
    echo ����j���R�W�ˬd... >> "%temp%\ClipInstaller.log"
    "%SN_TOOL%" -vf "%temp%\ClipClear.exe" >nul 2>&1
    if %errorlevel% equ 0 (
        echo ClipClear.exe �w�j���R�W�C >> "%temp%\ClipInstaller.log"
    ) else (
        echo ClipClear.exe ���j���R�W�C�p�G�z�ݭn�A�Эק�sĶ�ѼơC >> "%temp%\ClipInstaller.log"
    )
) else (
    echo �w���L�j���R�W�ˬd (sn.exe �����)�C >> "%temp%\ClipInstaller.log"
)

:: ��ñ����ñ�p�y�{
echo ���b�B�z��ñ���ҩMñ�p�{��... >> "%temp%\ClipInstaller.log"
powershell -NoProfile -Command ^
    "$certName = '%CERT_NAME%'; ^
    $pfxPasswordHash = '%PFX_PASSWORD_HASH%'; ^
    $exePath = '%temp%\ClipClear.exe'; ^
    $cert = Get-ChildItem Cert:\LocalMachine\My -CodeSigningCert | Where-Object { $_.Subject -eq 'CN=' + $certName }; ^
    if (-not $cert) { ^
        Write-Host '�����ñ�p���ҡA���b�إ߷s����...'; ^
        $cert = New-SelfSignedCertificate -Type CodeSigningCert -Subject ('CN=' + $certName) -CertStoreLocation 'Cert:\LocalMachine\My' -NotAfter (Get-Date).AddYears(5) -KeyUsage DigitalSignature -TextExtension @('2.5.29.37={text}1.3.6.1.5.5.7.3.3'); ^
        if (-not $cert) { Write-Error '�L�k�إߦ�ñ���ҡI'; exit 1 }; ^
        Write-Host '���Ҥw�إߡC���b�פJ�H���s���...'; ^
        try { ^
            $storeRoot = New-Object System.Security.Cryptography.X509Certificates.X509Store('Root','LocalMachine'); ^
            $storeRoot.Open('ReadWrite'); ^
            if (-not ($storeRoot.Certificates | Where-Object { $_.Thumbprint -eq $cert.Thumbprint })) { $storeRoot.Add($cert); Write-Host '�w�פJ�ܥ����H�����ھ��ұ��v�C' } else { Write-Host '���Ҥw�s�b�󥻾��H�����ھ��ұ��v�C' }; ^
            $storeRoot.Close(); ^
            $storePub = New-Object System.Security.Cryptography.X509Certificates.X509Store('TrustedPublisher','LocalMachine'); ^
            $storePub.Open('ReadWrite'); ^
            if (-not ($storePub.Certificates | Where-Object { $_.Thumbprint -eq $cert.Thumbprint })) { $storePub.Add($cert); Write-Host '�w�פJ�ܥ������H�����o��̡C' } else { Write-Host '���Ҥw�s�b�󥻾����H�����o��̡C' }; ^
            $storePub.Close(); ^
        } catch { Write-Error ('���ҶפJ���ѡG' + $_.Exception.Message); exit 1 } ^
    } else { ^
        Write-Host '���{��ñ�p���ҡC'; ^
    }; ^
    Write-Host '���b�ϥξ���ñ�p�{��...'; ^
    try { ^
        Get-ChildItem $exePath | Set-AuthenticodeSignature -Certificate $cert -TimestampServer http://timestamp.digicert.com/ -HashAlgorithm SHA256; ^
        $signature = Get-AuthenticodeSignature $exePath; ^
        if ($signature.Status -eq 'Valid') { Write-Host '�{��ñ�����\�I' } else { Write-Error ('�{��ñ�����ѡG' + $signature.StatusMessage); exit 1 }; ^
    } catch { Write-Error ('ñ�����ѡG' + $_.Exception.Message); exit 1 } ^
    " 2>> "%temp%\ClipInstaller.log"

if %errorlevel% neq 0 (
    echo ���~�Gñ���y�{���ѡA���ˬd��x�G%temp%\ClipInstaller.log
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
exit /b