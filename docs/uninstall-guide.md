# 解除安裝指南 | Uninstall Guide

## 🗑️ 完整解除安裝

### 方法一：使用解除安裝工具 (推薦)

1. **下載解除安裝工具**
   ```
   使用專案中的 tools/uninstall.bat
   ```

2. **執行解除安裝**
   - 以系統管理員身分執行 `uninstall.bat`
   - 程式會自動清除所有相關檔案和登錄項目

### 方法二：手動解除安裝

#### 步驟 1: 刪除程式檔案

```batch
# 刪除主程式 (需要管理員權限)
del "C:\Windows\System32\ClipClear.exe"

# 如果程式安裝在其他位置，也請一併刪除
del "原安裝目錄\ClipClear.exe"
```

#### 步驟 2: 清除登錄檔項目

```batch
# 清除檔案右鍵選單
reg delete "HKCR\*\shell\ClearClipboard" /f

# 清除桌面/資料夾背景右鍵選單
reg delete "HKCR\Directory\Background\shell\ClearClipboard" /f
```

#### 步驟 3: 清除暫存檔案

```batch
# 刪除編譯時產生的暫存檔案
del "%temp%\ClipboardClear_v3.cs"
del "%temp%\ClipClear.exe"
del "%temp%\ClipInstaller.log"
```

## 🔧 使用命令列解除安裝

開啟**命令提示字元 (系統管理員)**，執行以下命令：

```batch
@echo off
echo 正在解除安裝 ClearClipboard...

:: 停止可能正在執行的程序
taskkill /f /im ClipClear.exe 2>nul

:: 刪除程式檔案
echo 刪除程式檔案...
del "C:\Windows\System32\ClipClear.exe" 2>nul
del "ClipClear.exe" 2>nul

:: 清除登錄檔
echo 清除登錄檔項目...
reg delete "HKCR\*\shell\ClearClipboard" /f 2>nul
reg delete "HKCR\Directory\Background\shell\ClearClipboard" /f 2>nul

:: 清除暫存檔案
echo 清除暫存檔案...
del "%temp%\ClipboardClear_v3.cs" 2>nul
del "%temp%\ClipClear.exe" 2>nul
del "%temp%\ClipInstaller.log" 2>nul

echo 解除安裝完成！
pause
```

## ✅ 驗證解除安裝

### 檢查是否完全清除

1. **檔案驗證**
   ```batch
   # 確認主程式已刪除
   dir C:\Windows\System32\ClipClear.exe
   # 應該顯示「找不到檔案」
   ```

2. **右鍵選單驗證**
   - 在桌面空白處按滑鼠右鍵
   - 確認「一鍵清除剪貼簿」選項已消失
   - 選擇任意檔案按右鍵，同樣確認選項已消失

3. **登錄檔驗證**
   ```batch
   # 檢查登錄項目是否已清除
   reg query "HKCR\*\shell\ClearClipboard" 2>nul
   reg query "HKCR\Directory\Background\shell\ClearClipboard" 2>nul
   # 兩個命令都應該回傳「錯誤: 系統找不到指定的登錄機碼」
   ```

## 🔄 重新整理系統

解除安裝後建議執行以下操作：

### 重新整理檔案總管
```batch
# 重新啟動檔案總管以清除快取
taskkill /f /im explorer.exe
start explorer.exe
```

### 重新整理登錄檔快取 (可選)
```batch
# 重新啟動電腦以完全清除登錄檔快取
shutdown /r /t 0
```

## 🚨 解除安裝疑難排解

### 問題1：無法刪除程式檔案
**症狀**: 顯示「檔案正在使用中」或「拒絕存取」

**解決方案**:
```batch
# 1. 結束所有相關程序
taskkill /f /im ClipClear.exe

# 2. 重新啟動電腦後再嘗試刪除

# 3. 使用安全模式刪除
# 開機時按 F8 進入安全模式，然後刪除檔案
```

### 問題2：無法修改登錄檔
**症狀**: 顯示「拒絕存取」錯誤

**解決方案**:
```
1. 確保以系統管理員身分執行命令
2. 暫時停用防毒軟體的即時保護
3. 使用登錄檔編輯器 (regedit) 手動刪除
```

### 問題3：右鍵選單仍然存在
**症狀**: 解除安裝後右鍵選單項目仍然顯示

**解決方案**:
```
1. 重新啟動檔案總管
   taskkill /f /im explorer.exe
   start explorer.exe

2. 重新啟動電腦

3. 手動檢查和清除登錄檔項目
```

## 📂 手動清除登錄檔 (進階)

如果自動清除失敗，可使用登錄檔編輯器手動清除：

1. **開啟登錄檔編輯器**
   - 按 `Win + R`，輸入 `regedit`
   - 以系統管理員身分執行

2. **瀏覽到以下路徑**
   ```
   HKEY_CLASSES_ROOT\*\shell\ClearClipboard
   HKEY_CLASSES_ROOT\Directory\Background\shell\ClearClipboard
   ```

3. **刪除項目**
   - 右鍵點擊 `ClearClipboard` 資料夾
   - 選擇「刪除」
   - 確認刪除

## 🔒 安全注意事項

- **備份登錄檔**: 修改前建議備份相關登錄項目
- **管理員權限**: 確保有適當權限執行解除安裝
- **防毒軟體**: 某些防毒軟體可能阻止刪除系統檔案

## 📋 解除安裝檢查清單

- [ ] 刪除主程式檔案 (`ClipClear.exe`)
- [ ] 清除檔案右鍵選單項目
- [ ] 清除背景右鍵選單項目  
- [ ] 刪除暫存檔案
- [ ] 重新整理檔案總管
- [ ] 驗證右鍵選單已清除
- [ ] 檢查登錄檔項目已刪除

## 🔄 重新安裝

如需重新安裝：
1. 完成上述解除安裝步驟
2. 重新下載最新版本的安裝程式
3. 參考安裝指南重新安裝

---
**注意**: 解除安裝過程需要管理員權限，部分操作可能需要重新啟動電腦才能完全生效。