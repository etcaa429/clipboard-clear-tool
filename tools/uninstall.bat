@echo off
:: =============================================
:: uninstall.bat
:: 剪貼簿一鍵清理工具 - 解除安裝程式
:: 功能：移除右鍵選單、刪除執行檔、清理登錄檔
:: =============================================

echo ==========================================
echo    剪貼簿一鍵清理工具 - 解除安裝程式
echo ==========================================
echo.

:: 初始化日誌
echo [%date% %time%] 開始解除安裝 > "%temp%\ClipUninstaller.log"

:: 檢查管理者權限
fltmc >nul 2>&1 || (
    echo 正在請求管理員權限...
    echo 請在UAC提示中點選"是" >> "%temp%\ClipUninstaller.log"
    powershell -Command "Start-Process -FilePath '%~dpnx0' -Verb RunAs" & exit
)

echo [狀態] 現在為管理者權限 >> "%temp%\ClipUninstaller.log"
echo 正在移除剪貼簿清理工具...
echo.

:: ===== 移除登錄檔項目 =====
echo [1/3] 正在移除右鍵選單項目...
echo 移除登錄檔項目... >> "%temp%\ClipUninstaller.log"

:: 移除檔案右鍵選單
reg delete "HKCR\*\shell\ClearClipboard" /f >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✓ 檔案右鍵選單已移除
    echo   成功移除檔案右鍵選單 >> "%temp%\ClipUninstaller.log"
) else (
    echo   ! 檔案右鍵選單移除失敗或不存在
    echo   檔案右鍵選單移除失敗 >> "%temp%\ClipUninstaller.log"
)

:: 移除桌面/資料夾背景右鍵選單
reg delete "HKCR\Directory\Background\shell\ClearClipboard" /f >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✓ 桌面右鍵選單已移除
    echo   成功移除桌面右鍵選單 >> "%temp%\ClipUninstaller.log"
) else (
    echo   ! 桌面右鍵選單移除失敗或不存在
    echo   桌面右鍵選單移除失敗 >> "%temp%\ClipUninstaller.log"
)

:: ===== 刪除執行檔 =====
echo.
echo [2/3] 正在刪除執行檔...
echo 刪除執行檔... >> "%temp%\ClipUninstaller.log"

:: 刪除System32中的執行檔
if exist "%SystemRoot%\System32\ClipClear.exe" (
    del /f /q "%SystemRoot%\System32\ClipClear.exe" >nul 2>&1
    if not exist "%SystemRoot%\System32\ClipClear.exe" (
        echo   ✓ System32執行檔已刪除
        echo   成功刪除System32執行檔 >> "%temp%\ClipUninstaller.log"
    ) else (
        echo   ! System32執行檔刪除失敗
        echo   System32執行檔刪除失敗 >> "%temp%\ClipUninstaller.log"
    )
) else (
    echo   - System32中沒有找到執行檔
    echo   System32中沒有執行檔 >> "%temp%\ClipUninstaller.log"
)

:: 刪除當前目錄中的執行檔
if exist "%~dp0ClipClear.exe" (
    del /f /q "%~dp0ClipClear.exe" >nul 2>&1
    if not exist "%~dp0ClipClear.exe" (
        echo   ✓ 本地執行檔已刪除
        echo   成功刪除本地執行檔 >> "%temp%\ClipUninstaller.log"
    ) else (
        echo   ! 本地執行檔刪除失敗
        echo   本地執行檔刪除失敗 >> "%temp%\ClipUninstaller.log"
    )
) else (
    echo   - 本地目錄中沒有找到執行檔
    echo   本地目錄中沒有執行檔 >> "%temp%\ClipUninstaller.log"
)

:: ===== 清理暫存檔案 =====
echo.
echo [3/3] 正在清理暫存檔案...
echo 清理暫存檔案... >> "%temp%\ClipUninstaller.log"

:: 刪除編譯暫存檔
if exist "%temp%\ClipboardClear_v*.cs" (
    del /f /q "%temp%\ClipboardClear_v*.cs" >nul 2>&1
    echo   ✓ C#暫存檔已清理
    echo   C#暫存檔已清理 >> "%temp%\ClipUninstaller.log"
)

if exist "%temp%\ClipClear.exe" (
    del /f /q "%temp%\ClipClear.exe" >nul 2>&1
    echo   ✓ 暫存執行檔已清理
    echo   暫存執行檔已清理 >> "%temp%\ClipUninstaller.log"
)

:: ===== 完成報告 =====
echo.
echo ==========================================
echo            解除安裝完成報告
echo ==========================================
echo.
echo ✓ 解除安裝程序已完成
echo.
echo 已移除的項目：
echo   • 右鍵選單「一鍵清理剪貼簿」
echo   • ClipClear.exe 執行檔
echo   • 相關暫存檔案
echo.
echo 保留的項目：
echo   • 安裝/解除安裝日誌檔案
echo     (%temp%\ClipInstaller.log)
echo     (%temp%\ClipUninstaller.log)
echo.

:: 詢問是否刪除日誌檔案
set /p "delLog=是否要刪除日誌檔案? (Y/N): "
if /i "%delLog%"=="Y" (
    if exist "%temp%\ClipInstaller.log" del /f /q "%temp%\ClipInstaller.log" >nul 2>&1
    if exist "%temp%\ClipUninstaller.log" del /f /q "%temp%\ClipUninstaller.log" >nul 2>&1
    echo ✓ 日誌檔案已刪除
) else (
    echo - 日誌檔案已保留，如有問題可供參考
)

echo.
echo 感謝您使用剪貼簿一鍵清理工具！
echo.
echo 解除安裝完成日誌：%temp%\ClipUninstaller.log >> "%temp%\ClipUninstaller.log"

pause