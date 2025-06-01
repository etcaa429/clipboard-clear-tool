@echo off
:: =============================================
:: repair.bat - ClearClipboard 修復工具
:: 用途：診斷和修復 ClearClipboard 相關問題
:: 需求：管理員權限
:: =============================================

title ClearClipboard 修復工具 v1.0
color 0A

:: 初始化日誌
set "logFile=%temp%\ClipRepair.log"
echo [%date% %time%] === ClearClipboard 修復工具開始執行 === > "%logFile%"
echo 系統架構：%PROCESSOR_ARCHITECTURE% >> "%logFile%"

:: 檢查管理員權限
fltmc >nul 2>&1 || (
    echo ============================================
    echo  ⚠️  需要管理員權限
    echo ============================================
    echo 正在請求管理員權限...
    echo 請在UAC對話框中點選"是" >> "%logFile%"
    powershell -Command "Start-Process -FilePath '%~dpnx0' -Verb RunAs" & exit
)

:: 顯示標題
cls
echo ============================================
echo  🔧 ClearClipboard 修復工具 v1.0
echo ============================================
echo [成功] 已取得管理員權限
echo [資訊] 修復日誌：%logFile%
echo.

:: 主選單
:menu
echo ============================================
echo  修復選項
echo ============================================
echo 1. 🔍 診斷系統問題
echo 2. 🔧 修復右鍵選單
echo 3. 📁 重新安裝程式檔案
echo 4. 🧹 清理殘留檔案
echo 5. ♻️  完整重新安裝
echo 6. 📋 查看診斷報告
echo 7. 🚪 退出程式
echo ============================================
set /p choice=請選擇修復選項 (1-7): 

if "%choice%"=="1" goto :diagnose
if "%choice%"=="2" goto :fix_context_menu
if "%choice%"=="3" goto :reinstall_exe
if "%choice%"=="4" goto :cleanup
if "%choice%"=="5" goto :full_reinstall
if "%choice%"=="6" goto :show_report
if "%choice%"=="7" goto :exit
echo [錯誤] 無效選項，請重新選擇
pause
goto :menu

:: ===================
:: 1. 診斷系統問題
:: ===================
:diagnose
cls
echo ============================================
echo  🔍 系統診斷中...
echo ============================================
echo [診斷] 檢查系統配置... >> "%logFile%"

:: 檢查 .NET Framework
echo [1/8] 檢查 .NET Framework...
set "dotnetFound=0"
for %%i in (
    "%windir%\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
    "%windir%\Microsoft.NET\Framework\v4.0.30319\csc.exe"
) do if exist "%%i" (
    set "dotnetFound=1"
    echo [成功] 找到 .NET Framework 編譯器：%%i
    echo [診斷] .NET編譯器：%%i >> "%logFile%"
    goto :check_exe
)

if "%dotnetFound%"=="0" (
    echo [❌] 未找到 .NET Framework 4.x 編譯器
    echo [診斷] 錯誤：缺少.NET Framework >> "%logFile%"
)

:check_exe
:: 檢查主程式
echo [2/8] 檢查主程式檔案...
if exist "%SystemRoot%\System32\ClipClear.exe" (
    echo [✅] 主程式存在：%SystemRoot%\System32\ClipClear.exe
    echo [診斷] 主程式：System32存在 >> "%logFile%"
) else (
    echo [⚠️] 主程式不存在於 System32
    echo [診斷] 主程式：System32不存在 >> "%logFile%"
)

:: 檢查右鍵選單登錄項目
echo [3/8] 檢查右鍵選單註冊...
reg query "HKCR\*\shell\ClearClipboard" >nul 2>&1
if errorlevel 1 (
    echo [❌] 檔案右鍵選單未註冊
    echo [診斷] 檔案右鍵：未註冊 >> "%logFile%"
) else (
    echo [✅] 檔案右鍵選單已註冊
    echo [診斷] 檔案右鍵：已註冊 >> "%logFile%"
)

reg query "HKCR\Directory\Background\shell\ClearClipboard" >nul 2>&1
if errorlevel 1 (
    echo [❌] 背景右鍵選單未註冊
    echo [診斷] 背景右鍵：未註冊 >> "%logFile%"
) else (
    echo [✅] 背景右鍵選單已註冊
    echo [診斷] 背景右鍵：已註冊 >> "%logFile%"
)

:: 檢查程序運行狀態
echo [4/8] 檢查程序狀態...
tasklist /fi "imagename eq ClipClear.exe" 2>nul | find /i "ClipClear.exe" >nul
if errorlevel 1 (
    echo [✅] 沒有卡住的程序
    echo [診斷] 程序狀態：正常 >> "%logFile%"
) else (
    echo [⚠️] 發現運行中的 ClipClear.exe 程序
    echo [診斷] 程序狀態：有運行中程序 >> "%logFile%"
)

:: 檢查暫存檔案
echo [5/8] 檢查暫存檔案...
if exist "%temp%\ClipboardClear_v3.cs" (
    echo [⚠️] 發現殘留原始碼檔案
    echo [診斷] 暫存檔：有殘留 >> "%logFile%"
) else (
    echo [✅] 暫存檔案狀態正常
    echo [診斷] 暫存