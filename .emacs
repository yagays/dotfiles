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

;;全角スペース・タブを目立つように表示する
;;http://d.hatena.ne.jp/higepon/20060308/1141804526
(defface my-face-b-1 '((t (:background "medium aquamarine"))) nil)
(defface my-face-b-2 '((t (:background "gray26"))) nil)
(defface my-face-u-1 '((t (:foreground "SteelBlue" :underline t))) nil)
(defvar my-face-b-1 'my-face-b-1)
(defvar my-face-b-2 'my-face-b-2)
(defvar my-face-u-1 'my-face-u-1)
(defadvice font-lock-mode (before my-font-lock-mode ())
  (font-lock-add-keywords
   major-mode
   '(
     ("　" 0 my-face-b-1 append)
     ("\t" 0 my-face-b-2 append)
     ("[ ]+$" 0 my-face-u-1 append)
     )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)
(add-hook 'find-file-hooks '(lambda ()
(if font-lock-mode
nil
(font-lock-mode t))) t)

;; Buffer 設定
(iswitchb-mode 1) ;;iswitchbモードON
;;; C-f, C-b, C-n, C-p で候補を切り替えることができるように。
(add-hook 'iswitchb-define-mode-map-hook
      (lambda ()
       (define-key iswitchb-mode-map "\C-n" 'iswitchb-next-match)
       (define-key iswitchb-mode-map "\C-p" 'iswitchb-prev-match)
       (define-key iswitchb-mode-map "\C-f" 'iswitchb-next-match)
       (define-key iswitchb-mode-map "\C-b" 'iswitchb-prev-match)))
