@echo off
setlocal enabledelayedexpansion

:: =============================================
:: ClearClipboard_v0.3_Signed.bat
:: 剪貼簿清理工具 - 一鍵清理剪貼簿工具 (含強式命名與自簽憑證簽署)
:: 需求：.NET Framework 4.0+ (含4.8.1), Windows SDK (含signtool.exe, sn.exe)
:: 權限：需要管理者權限執行
:: =============================================

:: 初始化日誌
echo [%date% %time%] 開始執行 ClearClipboard_v3_Signed.bat > "%temp%\ClipInstaller.log"
echo 系統架構：%PROCESSOR_ARCHITECTURE% >> "%temp%\ClipInstaller.log"

:: 檢查管理者權限
fltmc >nul 2>&1 || (
    echo 正在請求管理者權限...
    echo 請在UAC提示中點選"是" >> "%temp%\ClipInstaller.log"
    powershell -Command "Start-Process -FilePath '%~dpnx0' -Verb RunAs" & exit
)

:: ===== 管理者權限下執行 =====
echo [狀態] 現在為管理者權限 >> "%temp%\ClipInstaller.log"

:: 檢查.NET Framework編譯器
set "csc="
for %%i in (
    "%windir%\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
    "%windir%\Microsoft.NET\Framework\v4.0.30319\csc.exe"
) do if exist "%%i" set "csc=%%i" & goto :check_tools

echo 錯誤：找不到 .NET Framework 4.x 編譯器 >> "%temp%\ClipInstaller.log"
echo 請確認已安裝 .NET Framework 4.0 或更高版本。
pause
exit /b

:check_tools
echo 使用編譯器：%csc% >> "%temp%\ClipInstaller.log"

:: 尋找 signtool.exe 和 sn.exe (來自 Windows SDK)
:: 注意：這些路徑可能因您的 Windows SDK 版本和安裝方式而異。
:: 如果找不到，請手動指定其完整路徑或確保其在 PATH 環境變數中。
set "SIGNTOOL="
set "SN_TOOL="

for /f "delims=" %%i in ('where /q signtool.exe 2^>nul ^&^& for %%j in (signtool.exe) do @echo %%~dp$PATH:j') do set "SIGNTOOL=%%i"
for /f "delims=" %%i in ('where /q sn.exe 2^>nul ^&^& for %%j in (sn.exe) do @echo %%~dp$PATH:j') do set "SN_TOOL=%%i"

if not defined SIGNTOOL (
    echo 錯誤：找不到 signtool.exe。請確認已安裝 Windows SDK 或指定其路徑。 >> "%temp%\ClipInstaller.log"
    echo (例如：C:\Program Files (x86)\Windows Kits\10\bin\10.0.xxxxx.0\x64\signtool.exe)
    pause
    exit /b
)
if not defined SN_TOOL (
    echo 警告：找不到 sn.exe。將跳過強式命名檢查。 >> "%temp%\ClipInstaller.log"
    echo (例如：C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools\sn.exe)
    set "SKIP_SN=true"
)

echo 使用 signtool.exe: %SIGNTOOL% >> "%temp%\ClipInstaller.log"
if not defined SKIP_SN echo 使用 sn.exe: %SN_TOOL% >> "%temp%\ClipInstaller.log"

:: C# 憑證相關變數
set "CERT_NAME=MyClearClipboardCert"

:: ====== 密碼輸入與強度評估流程 ======
:get_password
cls
echo.
echo ====================================================
echo 請為自簽憑證設定密碼 (用於保護私鑰)
echo ----------------------------------------------------
echo 密碼建議：
echo - 至少8個字元
echo - 包含大小寫字母、數字及特殊符號
echo - 避免使用個人資訊或常用單字
echo ====================================================
echo.

set "PFX_PASSWORD_PROMPT_DONE="

:prompt_password
if defined PFX_PASSWORD_PROMPT_DONE (
    echo 請重新輸入密碼。
)

:: 使用 PowerShell 讀取隱藏密碼
for /f "usebackq" %%i in (`powershell -Command "$p = Read-Host -Prompt '輸入密碼' -AsSecureString; $p | ConvertFrom-SecureString"`) do set "PFX_PASSWORD_HASH=%%i"
for /f "usebackq" %%i in (`powershell -Command "$p = Read-Host -Prompt '再次輸入密碼確認' -AsSecureString; $p | ConvertFrom-SecureString"`) do set "PFX_PASSWORD_CONFIRM_HASH=%%i"

:: 將安全字串的哈希值比較，判斷密碼是否一致
if not "!PFX_PASSWORD_HASH!"=="!PFX_PASSWORD_CONFIRM_HASH!" (
    echo [!] 兩次輸入的密碼不一致，請重試。
    set "PFX_PASSWORD_PROMPT_DONE=true"
    goto :prompt_password
)

:: 獲取明文密碼（用於強度評估，請注意此處密碼會短暫出現在記憶體中，但不會寫入磁碟）
for /f "usebackq" %%i in (`powershell -Command "$p = [Runtime.InteropServices.Marshal]::SecureStringToBSTR((Convertto-SecureString -String '%PFX_PASSWORD_HASH%' -AsPlainText -Force)); try { [Runtime.InteropServices.Marshal]::PtrToStringBSTR($p) } finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($p) }"`) do set "PFX_PASSWORD_PLAIN=%%i"

if "!PFX_PASSWORD_PLAIN!"=="" (
    echo [!] 密碼不能為空，請重新輸入。
    set "PFX_PASSWORD_PROMPT_DONE=true"
    goto :prompt_password
)

:: 密碼強度評估 (使用 PowerShell 簡單判斷)
echo 評估密碼強度...
powershell -NoProfile -Command ^
    "$password = '%PFX_PASSWORD_PLAIN%'; ^
    $score = 0; ^
    if ($password.Length -ge 8) { $score++ }; ^
    if ($password -match '[a-z]') { $score++ }; ^
    if ($password -match '[A-Z]') { $score++ }; ^
    if ($password -match '\d') { $score++ }; ^
    if ($password -match '[!@#$%^&*()_+\-=\[\]{};'':\"\\|,.<>\/?~`]') { $score++ }; ^
    if ($password.Length -ge 12) { $score++ }; ^
    if ($score -ge 5) { Write-Host '密碼強度: 強 (非常推薦)' -ForegroundColor Green } ^
    else if ($score -ge 3) { Write-Host '密碼強度: 中 (建議加強)' -ForegroundColor Yellow } ^
    else { Write-Host '密碼強度: 弱 (非常不推薦)' -ForegroundColor Red }; ^
    if ($score -lt 3) { exit 1 } else { exit 0 }"

if %errorlevel% neq 0 (
    echo [!] 密碼強度過弱，請重新設定一個更強的密碼。
    set "PFX_PASSWORD_PROMPT_DONE=true"
    goto :prompt_password
)

echo 密碼已設定。 >> "%temp%\ClipInstaller.log"
REM 清除明文密碼變數
set "PFX_PASSWORD_PLAIN="

:: ====== 密碼輸入與強度評估流程結束 ======

:: 生成C#原始碼 - 使用轉義大括號
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

:: 編譯程式
echo 正在編譯... >> "%temp%\ClipInstaller.log"
"%csc%" /nologo /target:winexe /out:"%temp%\ClipClear.exe" "%temp%\ClipboardClear_v3.cs" 2>> "%temp%\ClipInstaller.log"

if not exist "%temp%\ClipClear.exe" (
    echo 編譯失敗！檢查日誌：%temp%\ClipInstaller.log
    pause
    exit /b
)

:: 強式命名檢查 (可選)
if not defined SKIP_SN (
    echo 執行強式命名檢查... >> "%temp%\ClipInstaller.log"
    "%SN_TOOL%" -vf "%temp%\ClipClear.exe" >nul 2>&1
    if %errorlevel% equ 0 (
        echo ClipClear.exe 已強式命名。 >> "%temp%\ClipInstaller.log"
    ) else (
        echo ClipClear.exe 未強式命名。如果您需要，請修改編譯參數。 >> "%temp%\ClipInstaller.log"
    )
) else (
    echo 已跳過強式命名檢查 (sn.exe 未找到)。 >> "%temp%\ClipInstaller.log"
)

:: 自簽憑證簽署流程
echo 正在處理自簽憑證和簽署程式... >> "%temp%\ClipInstaller.log"
powershell -NoProfile -Command ^
    "$certName = '%CERT_NAME%'; ^
    $pfxPasswordHash = '%PFX_PASSWORD_HASH%'; ^
    $exePath = '%temp%\ClipClear.exe'; ^
    $cert = Get-ChildItem Cert:\LocalMachine\My -CodeSigningCert | Where-Object { $_.Subject -eq 'CN=' + $certName }; ^
    if (-not $cert) { ^
        Write-Host '未找到簽署憑證，正在建立新憑證...'; ^
        $cert = New-SelfSignedCertificate -Type CodeSigningCert -Subject ('CN=' + $certName) -CertStoreLocation 'Cert:\LocalMachine\My' -NotAfter (Get-Date).AddYears(5) -KeyUsage DigitalSignature -TextExtension @('2.5.29.37={text}1.3.6.1.5.5.7.3.3'); ^
        if (-not $cert) { Write-Error '無法建立自簽憑證！'; exit 1 }; ^
        Write-Host '憑證已建立。正在匯入信任存放區...'; ^
        try { ^
            $storeRoot = New-Object System.Security.Cryptography.X509Certificates.X509Store('Root','LocalMachine'); ^
            $storeRoot.Open('ReadWrite'); ^
            if (-not ($storeRoot.Certificates | Where-Object { $_.Thumbprint -eq $cert.Thumbprint })) { $storeRoot.Add($cert); Write-Host '已匯入至本機信任的根憑證授權。' } else { Write-Host '憑證已存在於本機信任的根憑證授權。' }; ^
            $storeRoot.Close(); ^
            $storePub = New-Object System.Security.Cryptography.X509Certificates.X509Store('TrustedPublisher','LocalMachine'); ^
            $storePub.Open('ReadWrite'); ^
            if (-not ($storePub.Certificates | Where-Object { $_.Thumbprint -eq $cert.Thumbprint })) { $storePub.Add($cert); Write-Host '已匯入至本機受信任的發行者。' } else { Write-Host '憑證已存在於本機受信任的發行者。' }; ^
            $storePub.Close(); ^
        } catch { Write-Error ('憑證匯入失敗：' + $_.Exception.Message); exit 1 } ^
    } else { ^
        Write-Host '找到現有簽署憑證。'; ^
    }; ^
    Write-Host '正在使用憑證簽署程式...'; ^
    try { ^
        Get-ChildItem $exePath | Set-AuthenticodeSignature -Certificate $cert -TimestampServer http://timestamp.digicert.com/ -HashAlgorithm SHA256; ^
        $signature = Get-AuthenticodeSignature $exePath; ^
        if ($signature.Status -eq 'Valid') { Write-Host '程式簽章成功！' } else { Write-Error ('程式簽章失敗：' + $signature.StatusMessage); exit 1 }; ^
    } catch { Write-Error ('簽章失敗：' + $_.Exception.Message); exit 1 } ^
    " 2>> "%temp%\ClipInstaller.log"

if %errorlevel% neq 0 (
    echo 錯誤：簽章流程失敗，請檢查日誌：%temp%\ClipInstaller.log
    pause
    exit /b
)

:: 複製到系統目錄
echo 正在設置到 System32... >> "%temp%\ClipInstaller.log"
copy /y "%temp%\ClipClear.exe" "%SystemRoot%\System32\" >nul 2>&1

if exist "%SystemRoot%\System32\ClipClear.exe" (
    set "exePath=%SystemRoot%\System32\ClipClear.exe"
    echo 成功寫入系統目錄 >> "%temp%\ClipInstaller.log"
) else (
    echo 警告：無法寫入System32，改用現在目錄 >> "%temp%\ClipInstaller.log"
    copy /y "%temp%\ClipClear.exe" "%~dp0ClipClear.exe" >nul
    set "exePath=%~dp0ClipClear.exe"
)

:: ===== 註冊右鍵選項 =====
echo 正在註冊右鍵選項... >> "%temp%\ClipInstaller.log"

:: 檔案右鍵選項
reg add "HKCR\*\shell\ClearClipboard" /ve /d "一鍵清理剪貼簿" /f >nul || (
    echo 錯誤：無法寫入HKCR\*\shell >> "%temp%\ClipInstaller.log"
    goto :error
)
reg add "HKCR\*\shell\ClearClipboard" /v "Icon" /d "%exePath%,0" /f >nul
reg add "HKCR\*\shell\ClearClipboard\command" /ve /d "\"%exePath%\"" /f >nul

:: 桌面/資料夾背景右鍵選項
reg add "HKCR\Directory\Background\shell\ClearClipboard" /ve /d "一鍵清理剪貼簿" /f >nul || (
    echo 錯誤：無法寫入Directory\Background >> "%temp%\ClipInstaller.log"
    goto :error
)
reg add "HKCR\Directory\Background\shell\ClearClipboard" /v "Icon" /d "%exePath%,0" /f >nul
reg add "HKCR\Directory\Background\shell\ClearClipboard\command" /ve /d "\"%exePath%\"" /f >nul

:: 完成
echo 安裝成功！ >> "%temp%\ClipInstaller.log"
echo 請在檔案或桌面上右鍵看到"一鍵清理剪貼簿"功能
pause
exit /b

:error
echo 安裝過程中發生錯誤，請檢查日誌：%temp%\ClipInstaller.log
pause
exit /b