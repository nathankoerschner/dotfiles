;; Move customization variables to a separate file and load it
(setq custom-file (locate-user-emacs-file "custom-vars.el"))
(load custom-file 'noerror 'nomessage)

;; PACKAGES
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

;; KEY BINDINGS

;; evil-mode
(use-package evil
  :ensure t
  :config
  (evil-define-key 'normal org-mode-map (kbd "<tab>") #'org-cycle)
  (evil-mode t))  
;; no :pin needed, as package.el will choose the version in melpa

;; TOOLS

;; org-mode
(use-package org
  :ensure t
  ;; ignore org-mode from upstream and use a manually installed version
)

;; denote
(use-package denote
  :ensure t
  ;; ignore org-mode from upstream and use a manually installed version
)

;; UI

(global-display-line-numbers-mode 1) ; show line numbers
(tool-bar-mode -1) ; hide the toolbar (which has save icon button and so forth)
(hl-line-mode 1) ; highlight the current line


;; Revert buffers when the underlying file has changed
(global-auto-revert-mode 1)
;; Revert Dired and other buffers
(setq global-auto-revert-non-file-buffers t)



;; THEME AND APPEARANCE
(set-face-attribute 'default nil :height 180)


;; inhibit startup message
(setq inhibit-startup-message t)

;; Theme: zenburn
(use-package zenburn-theme
  :ensure t
  :config
  (load-theme 'zenburn t)
)


