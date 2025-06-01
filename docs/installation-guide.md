# 安裝指南 | Installation Guide

## 📋 系統需求

### 最低需求
- **作業系統**: Windows 7/8/10/11 (32位元或64位元)
- **.NET Framework**: 4.0 或更高版本 (建議 4.8.1)
- **權限**: 系統管理員權限 (UAC提升)

### 相容性檢查
程式會自動檢測您的系統配置：
- 處理器架構 (x86/x64)
- .NET Framework 版本
- 管理員權限狀態

## 🚀 安裝步驟

### 方法一：快速安裝 (推薦)

1. **下載程式**
   ```
   下載 ClearClipboard.bat 到任意資料夾
   ```

2. **執行安裝**
   - 滑鼠右鍵點擊 `ClearClipboard.bat`
   - 選擇「以系統管理員身分執行」
   - 或直接雙擊，程式會自動要求提升權限

3. **UAC授權**
   - 當出現使用者帳戶控制視窗時
   - 點擊「是」允許程式執行

4. **等待完成**
   - 程式會自動編譯和安裝
   - 看到「安裝成功！」訊息即完成

### 方法二：命令列安裝

```batch
# 開啟命令提示字元 (以系統管理員身分)
cd /d "C:\path\to\download\folder"
ClearClipboard.bat
```

## 📁 安裝位置說明

### 主程式位置
- **優先位置**: `C:\Windows\System32\ClipClear.exe`
- **備用位置**: 與批次檔同目錄下的 `ClipClear.exe`

### 登錄檔項目
程式會在以下位置建立右鍵選單項目：

```
HKEY_CLASSES_ROOT\*\shell\ClearClipboard
HKEY_CLASSES_ROOT\Directory\Background\shell\ClearClipboard
```

## ✅ 安裝驗證

### 檢查安裝是否成功

1. **檔案驗證**
   ```batch
   # 檢查主程式是否存在
   dir C:\Windows\System32\ClipClear.exe
   ```

2. **功能測試**
   - 複製任意文字到剪貼簿
   - 在桌面空白處按滑鼠右鍵
   - 查看是否出現「一鍵清除剪貼簿」選項
   - 點擊該選項測試功能

3. **日誌檢查**
   ```
   查看安裝日誌：%temp%\ClipInstaller.log
   ```

## 🔧 常見安裝問題

### 問題1：找不到 .NET Framework 編譯器
**症狀**: 顯示「錯誤：找不到 .NET Framework 4.x 編譯器」

**解決方案**:
```
1. 下載並安裝 .NET Framework 4.8.1
   https://dotnet.microsoft.com/download/dotnet-framework
2. 重新啟動電腦
3. 重新執行安裝程式
```

### 問題2：編譯失敗
**症狀**: 顯示「編譯失敗！檢查日誌」

**解決方案**:
```
1. 檢查 %temp%\ClipInstaller.log 詳細錯誤訊息
2. 確保有足夠的磁碟空間
3. 暫時關閉防毒軟體
4. 重新執行安裝
```

### 問題3：無法寫入 System32
**症狀**: 程式安裝到當前目錄而非 System32

**解決方案**:
```
這是正常的降級行為，程式仍可正常運作
如需安裝到 System32：
1. 確保以完整管理員權限執行
2. 檢查是否被安全軟體阻擋
```

### 問題4：右鍵選單沒有出現
**症狀**: 安裝完成但右鍵選單中看不到選項

**解決方案**:
```
1. 重新啟動 Windows 檔案總管
   taskkill /f /im explorer.exe
   start explorer.exe

2. 或重新啟動電腦

3. 檢查登錄檔是否正確寫入
```

## 📊 安裝日誌說明

安裝過程會記錄到 `%temp%\ClipInstaller.log`：

```
[日期 時間] 開始執行
系統架構：AMD64
[成功] 現在為管理員權限
使用編譯器：C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe
正在編譯...
成功寫入系統目錄
正在註冊右鍵選項...
安裝成功！
```

## 🎯 安裝後設定

### 自訂圖示 (可選)
程式預設使用執行檔圖示，如需自訂：

```batch
# 修改登錄檔圖示路徑
reg add "HKCR\*\shell\ClearClipboard" /v "Icon" /d "C:\path\to\custom\icon.ico" /f
```

### 自訂顯示文字 (可選)
```batch
# 修改右鍵選單顯示文字
reg add "HKCR\*\shell\ClearClipboard" /ve /d "您的自訂文字" /f
```

## 🔄 重新安裝

如需重新安裝：
1. 先執行解除安裝 (參考 uninstall-guide.md)
2. 重新執行安裝步驟
3. 或直接執行安裝程式覆蓋舊版本

## 📞 技術支援

如遇到安裝問題：
1. 檢查安裝日誌檔案
2. 查閱疑難排解文件 (troubleshooting.md)
3. 使用修復工具 (repair.bat)
4. 提交 Issue 回報問題

---
**注意**: 安裝過程需要管理員權限，請確保您有適當的系統權限。