#!/bin/bash
# cmux global hotkey toggle (Karabiner の Ctrl+Shift+U から呼ばれる)
#   - cmux が最前面なら隠す (直前のアプリに戻る)
#   - それ以外なら最前面に持ってくる (未起動なら起動)
#
# 注: 最前面判定と「隠す」に System Events を使うため、初回実行時に
#     "karabiner_console_user_server" に対する自動化 (System Events を
#     制御する) の許可ダイアログが出る。許可しないと隠す動作が効かない
#     (前面化は open なので許可不要)。

BUNDLE="com.cmuxterm.app"

front=$(osascript -e 'tell application "System Events" to get bundle identifier of first process whose frontmost is true' 2>/dev/null)

if [ "$front" = "$BUNDLE" ]; then
    # 最前面 -> 隠す
    osascript -e "tell application \"System Events\" to set visible of (first process whose bundle identifier is \"$BUNDLE\") to false"
else
    # それ以外 -> 前面化 / 起動
    /usr/bin/open -b "$BUNDLE"
fi
