# 🔧 疑難排解指南

本指南包含常見問題的解決方案，幫助您快速排除使用上遇到的問題。

## 📋 目錄
- [安裝相關問題](#-安裝相關問題)
- [執行相關問題](#-執行相關問題)
- [右鍵選單問題](#-右鍵選單問題)
- [權限相關問題](#-權限相關問題)
- [系統相容性問題](#-系統相容性問題)
- [進階診斷](#-進階診斷)

---

## 🛠️ 安裝相關問題

### Q1: 執行時出現「不應有 {」錯誤
**症狀**: 執行bat檔時顯示語法錯誤
**原因**: 批次檔解析大括號時發生問題
**解決方案**:
1. 確保使用最新版本的bat檔案
2. 以系統管理員身分執行
3. 檢查檔案是否完整下載（沒有損壞）

### Q2: 找不到 .NET Framework 編譯器
**症狀**: 顯示「找不到 .NET Framework 4.x 編譯器」
**原因**: 系統缺少必要的 .NET Framework
**解決方案**:
1. 下載並安裝 [.NET Framework 4.8](https://dotnet.microsoft.com/download/dotnet-framework/net48)
2. 重新啟動電腦
3. 重新執行安裝程式

### Q3: 編譯失敗
**症狀**: 安裝過程中編譯步驟失敗
**診斷步驟**:
1. 檢查日誌檔案：`%temp%\ClipInstaller.log`
2. 確認C#原始檔是否正確生成：`%temp%\ClipboardClear_v3.cs`
3. 檢查編譯器路徑是否正確

**解決方案**:
```batch
# 手動檢查編譯器是否存在
dir "%windir%\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
dir "%windir%\Microsoft.NET\Framework\v4.0.30319\csc.exe"
```

---

## ⚡ 執行相關問題

### Q4: UAC提示沒有出現
**症狀**: 程式沒有要求管理員權限
**原因**: UAC設定問題或權限已足夠
**解決方案**:
1. 右鍵點選bat檔案
2. 選擇「以系統管理員身分執行」
3. 如果UAC被停用，需要手動啟用

### Q5: 安裝後沒有成功訊息
**症狀**: 程式執行但沒有顯示完成訊息
**診斷步驟**:
1. 檢查是否真的以管理員身分執行
2. 查看日誌檔案內容
3. 確認防毒軟體沒有攔截

---

## 🖱️ 右鍵選單問題

### Q6: 右鍵選單沒有出現「一鍵清理剪貼簿」
**症狀**: 安裝完成但右鍵選單中找不到選項
**診斷步驟**:
1. 檢查登錄檔是否寫入成功：
```cmd
reg query "HKCR\*\shell\ClearClipboard"
reg query "HKCR\Directory\Background\shell\ClearClipboard"
```

**解決方案**:
1. 確認以管理員身分安裝
2. 重新啟動檔案總管：
   - 按 `Ctrl+Shift+Esc` 開啟工作管理員
   - 找到「Windows檔案總管」
   - 結束工作並重新啟動
3. 重新執行安裝程式

### Q7: 右鍵選單選項點選沒反應
**症狀**: 選單項目存在但點選後沒有效果
**原因**: 執行檔路徑錯誤或檔案不存在
**診斷步驟**:
1. 檢查執行檔是否存在：
```cmd
dir "%SystemRoot%\System32\ClipClear.exe"
```
2. 檢查登錄檔中的路徑是否正確

**解決方案**:
1. 重新執行安裝程式
2. 如果問題持續，使用解除安裝工具後重新安裝

---

## 🔐 權限相關問題

### Q8: 無法寫入System32目錄
**症狀**: 警告訊息「無法寫入System32，改用現在目錄」
**原因**: 即使是管理員也可能受到某些安全軟體限制
**解決方案**:
1. 這是正常行為，程式會自動使用備用方案
2. 執行檔會放在bat檔案所在目錄
3. 功能不受影響

### Q9: 登錄檔寫入失敗
**症狀**: 錯誤訊息顯示無法寫入HKCR
**原因**: 權限不足或登錄檔被保護
**解決方案**:
1. 確保以完整管理員權限執行
2. 暫時停用過度保護的安全軟體
3. 檢查Windows是否處於安全模式

---

## 💻 系統相容性問題

### Q10: Windows 7 相容性問題
**症狀**: 在Windows 7上執行失敗
**解決方案**:
1. 確保安裝了所有Windows Update
2. 安裝 [.NET Framework 4.8](https://support.microsoft.com/zh-tw/help/4503548)
3. 確認PowerShell版本至少為2.0

### Q11: 32位元系統問題
**症狀**: 64位元系統編譯器路徑錯誤
**原因**: 程式優先尋找64位元編譯器
**解決方案**:
程式會自動回退到32位元編譯器，這是正常行為。

---

## 🔍 進階診斷

### 檢查日誌檔案
安裝日誌位置：`%temp%\ClipInstaller.log`
```batch
# 開啟日誌檔案
notepad "%temp%\ClipInstaller.log"
```

### 手動測試剪貼簿清理
1. 複製一些文字到剪貼簿
2. 執行：`%SystemRoot%\System32\ClipClear.exe`
3. 嘗試貼上，應該沒有內容

### 檢查登錄檔項目
```cmd
# 檢查檔案右鍵選單
reg query "HKCR\*\shell\ClearClipboard" /s

# 檢查桌面右鍵選單  
reg query "HKCR\Directory\Background\shell\ClearClipboard" /s
```

### 系統資訊收集
執行以下命令收集系統資訊：
```cmd
echo 系統資訊：
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type"

echo .NET Framework 版本：
reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" /v Release
```

---

## 🆘 仍然無法解決？

如果按照上述步驟仍無法解決問題，請：

1. **檢查日誌檔案**：將 `%temp%\ClipInstaller.log` 的內容複製
2. **收集系統資訊**：作業系統版本、架構、.NET版本
3. **建立Issue**：到 [GitHub Issues](https://github.com/your-username/clipboard-clear-tool/issues) 建立問題回報
4. **提供詳細資訊**：包含錯誤訊息、系統資訊和日誌內容

## 📞 取得協助

- 📝 [建立Issue](https://github.com/your-username/clipboard-clear-tool/issues/new)
- 💬 [GitHub Discussions](https://github.com/your-username/clipboard-clear-tool/discussions)
- 📧 電子郵件：your-email@example.com

---

**最後更新**: 2025年6月  
**適用版本**: v1.0.0+