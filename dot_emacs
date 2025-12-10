;;==================================================
;; 基本設定
;;==================================================

;;load-path
(setq load-path (cons "~/.emacs.d/elisp" load-path))

;; cl
(require 'cl)

;; バックアップファイルを作らない
(setq backup-inhibited t)

;;; *.~ とかのバックアップファイルを作らない
(setq make-backup-files nil)
;;; .#* とかのバックアップファイルを作らない
(setq auto-save-default nil)

;; C-hでbackspace
(global-set-key "\C-h" 'delete-backward-char)

;; BS で選択範囲を消す
(delete-selection-mode 1)

;; シフト + 矢印で範囲選択
;; (setq pc-select-selection-keys-only t)
;; (pc-selection-mode 1)

;;文字を右端で折り返す
(setq truncate-lines nil)
(setq truncate-partial-width-windows nil)

;;1行ずつスクロール
(setq scroll-conservatively 35
       scroll-margin 0
       scroll-step 1)

;;yes or no をy or nにする
(fset 'yes-or-no-p 'y-or-n-p)

;; ビープ音を消す
(setq visible-bell t)
(setq ring-bell-function 'ignore)

;; スタートアップページを表示しない
(setq inhibit-startup-message t)
;; scratchの初期メッセージ消去
(setq initial-scratch-message "")

;; モードラインに行番号表示
(line-number-mode t)
;; モードラインに列番号表示
(column-number-mode t)

;;カギ括弧の両端をハイライト
(show-paren-mode 1)
