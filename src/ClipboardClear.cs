// ClipboardClear_v2.cs
// 命令列模式清理剪貼簿緩存工具程式
// try-catch (Exception) 捕獲異常狀態並回傳錯誤碼(防止程式崩潰彈出視窗)
// 錯誤碼用途：
// 0：成功
// 1：未知錯誤
// 2：剪貼簿繁忙
// 3：執行緒模式錯誤
using System;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using System.Threading;

class Program {
    [STAThread]
    static void Main() {
        try {
            Clipboard.Clear();
        } catch (ExternalException) {
            // 剪貼簿被鎖定
            Environment.Exit(2); 
        } catch (ThreadStateException) {
            // 非 STA 執行緒問題
            Environment.Exit(3);
        } catch (Exception) {
            Environment.Exit(1);
        }
    }
}