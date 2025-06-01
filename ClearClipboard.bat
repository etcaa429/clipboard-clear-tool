@echo off
:: =============================================
:: ClearClipboard_v3.bat
:: 剪貼簿清理工具 - 一鍵清理剪貼簿工具
:: 需求：.NET Framework 4.0+ (含4.8.1)
:: 權限：需要管理者權限執行
:: =============================================

:: 初始化日誌
echo [%date% %time%] 開始執行 > "%temp%\ClipInstaller.log"
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
) do if exist "%%i" set "csc=%%i" & goto :compile

echo 錯誤：找不到 .NET Framework 4.x 編譯器 >> "%temp%\ClipInstaller.log"
echo 請確認已安裝 .NET Framework 4.0 或更高版本
pause
exit /b

:compile
echo 使用編譯器：%csc% >> "%temp%\ClipInstaller.log"

:: 生成C#原始碼 - 使用轉義大括號
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

:: 編譯程式
echo 正在編譯... >> "%temp%\ClipInstaller.log"
"%csc%" /nologo /target:winexe /out:"%temp%\ClipClear.exe" "%temp%\ClipboardClear_v3.cs" 2>> "%temp%\ClipInstaller.log"

if not exist "%temp%\ClipClear.exe" (
    echo 編譯失敗！檢查日誌：%temp%\ClipInstaller.log
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