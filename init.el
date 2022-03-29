;; brew install ripgrep gopls

(when (display-graphic-p)
  (tool-bar-mode 0)
  (scroll-bar-mode 0))
(setq inhibit-startup-screen t)

;; Dark theme.
(load-theme 'wombat)
(set-face-background 'default "#111")
(set-face-background 'cursor "#c96")
(set-face-background 'isearch "#c60")
(set-face-foreground 'isearch "#eee")
(set-face-background 'lazy-highlight "#960")
(set-face-foreground 'lazy-highlight "#ccc")
(set-face-foreground 'font-lock-comment-face "#fc0")

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

(add-to-list 'exec-path "/Users/habib/go/bin")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cua-mode t nil (cua-base))
 '(package-selected-packages
   '(yaml-mode projectile auto-dim-other-buffers unicode-fonts super-save smartparens golden-ratio dap-mode company-lsp company company-go lsp-ui yasnippet exec-path-from-shell go-mode))
 '(save-place-mode t)
 '(show-paren-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :inverse-video nil :box nil :strike-through nil :extend nil :overline nil :underline nil :slant normal :weight normal :height 140 :width normal :foundry "nil" :family "Menlo"))))
 '(auto-dim-other-buffers-face ((t (:background "#132"))))
 '(hl-line ((t (:background "#451010")))))

(column-number-mode 1)

;; add doneburn-theme to package-selected-packages above if you want to use it
;; (use-package doneburn-theme
;;   :ensure t
;;   :config (load-theme 'doneburn 'no-confirm))

; Set cursor color to red
;(set-cursor-color "#ff0000")

(use-package hl-line
   :custom-face
   (hl-line ((t (:background "#451010")))))
;;Other colors that I like are #2b4247 
(global-hl-line-mode 1)

;(require 'lsp-mode)
;(add-hook 'go-mode-hook #'lsp)
;(add-hook 'before-save-hook 'gofmt-before-save)

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook (go-mode . lsp-deferred))

(use-package dap-mode)
(use-package dap-go)

(setq lsp-gopls-staticcheck t)
(setq lsp-eldoc-render-all t)
(setq lsp-gopls-complete-unimported t)

;;Set up before-save hooks to format buffer and add/delete imports.
;;Make sure you don't have other gofmt/goimports hooks enabled.

(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

;;Optional - provides fancier overlays.

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :init)

(require 'smartparens-config)
(add-hook 'go-mode-hook #'smartparens-mode)

;;Company mode is a standard completion package that works well with lsp-mode.
;;company-lsp integrates company mode completion with lsp-mode.
;;completion-at-point also works out of the box but doesn't support snippets.

(use-package company
  :ensure t
  :config
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 1))

;;Optional - provides snippet support.

(use-package yasnippet
  :ensure t
  :commands yas-minor-mode
  :hook (go-mode . yas-minor-mode))

;; Use flycheck instead of flymake since it is more modern
(require 'flycheck)
(global-flycheck-mode 1)
(setq flycheck-checker-error-threshold 1000) ; for large go files and the escape checker

;;lsp-ui-doc-enable is false because I don't like the popover that shows up on the right
;;I'll change it if I want it back
(setq lsp-ui-doc-enable nil
      lsp-ui-peek-enable t
      lsp-ui-sideline-enable t
      lsp-ui-imenu-enable t
      lsp-ui-flycheck-enable t)

;(require 'yasnippet)
(yas-global-mode 1)

;; Advanced git interface.
(require 'magit)
(setq magit-fetch-modules-jobs 16)

;; Helm: incremental completion and selection narrowing inside menus/lists
;; (require 'helm)
;; (require 'helm-config)
;; (require 'helm-projectile)
;; (helm-mode 1)
;; (helm-projectile-on)

;; (setq helm-split-window-inside-p            t ; open helm buffer inside current window, not occupy whole other window
;;       helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
;;       helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
;;       helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
;;       helm-ff-file-name-history-use-recentf t
;;       helm-echo-input-in-header-line t)

(global-display-line-numbers-mode)

(use-package go-mode
:defer t
:ensure t
:mode ("\\.go\\'" . go-mode)
:init
  (setq compile-command "echo Building... && go build -v && echo Testing... && go test -v && echo Linter... && golint")
  (setq compilation-read-command nil)
:bind (("M-," . compile)
("M-." . godef-jump)))

(setq compilation-window-height 14)
(defun my-compilation-hook ()
  (when (not (get-buffer-window "*compilation*"))
    (save-selected-window
      (save-excursion
	(let* ((w (split-window-vertically))
	       (h (window-height w)))
	  (select-window w)
	  (switch-to-buffer "*compilation*")
	  (shrink-window (- h compilation-window-height)))))))
(add-hook 'compilation-mode-hook 'my-compilation-hook)

(global-set-key (kbd "C-c C-c") 'comment-or-uncomment-region)
(setq compilation-scroll-output t)

(add-hook 'go-mode-hook (lambda ()
                          (setq tab-width 4)))

(setq-default tab-width 4)
(setq c-basic-offset 4)
(setq js-indent-level 2)
(setq css-indent-offset 2)

(ido-mode 1)
(ido-everywhere)
(fido-mode)
(setq ido-enable-flex-matching t)

(setq-default show-trailing-whitespace t)
(setq-default indicate-empty-lines t)
(setq-default indicate-buffer-boundaries 'left)

(setq sentence-end-double-space nil)
(setq-default indent-tabs-mode nil)

;;Autosave files section
(make-directory "~/.tmp/emacs/auto-save/" t)
(setq auto-save-file-name-transforms '((".*" "~/.tmp/emacs/auto-save/" t)))
(setq backup-directory-alist '(("." . "~/.tmp/emacs/backup/")))
(setq backup-by-copying t)
(setq create-lockfiles nil)
(super-save-mode +1)
(setq super-save-auto-save-when-idle t)
(setq auto-save-default nil)

;; Didn't quite like golden-ratio mode
;;(require 'golden-ratio)
;;(golden-ratio-mode 1)

;; Auto dim inactive buffers
(add-hook 'after-init-hook (lambda ()
  (when (fboundp 'auto-dim-other-buffers-mode)
    (auto-dim-other-buffers-mode t))))

;;ripgrep settings. Install ripgrep first
(require 'grep)
(grep-apply-setting 'grep-find-command
                    '("rg -n -H --no-heading -e '' $(git rev-parse --show-toplevel || pwd)" . 27))
(global-set-key (kbd "C-x C-g") 'grep-find)

;; Adding projectile mode
(projectile-mode +1)
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)

;; Adding yaml mode
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode))

;; https://dr-knz.net/a-tour-of-emacs-as-go-editor.html
;; https://github.com/habib/emfy
