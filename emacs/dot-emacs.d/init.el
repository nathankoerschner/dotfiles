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


;; UI

(global-display-line-numbers-mode 1) ; show line numbers
(tool-bar-mode -1) ; hide the toolbar (which has save icon button and so forth)
(hl-line-mode 1) ; highlight the current line





;; THEME AND APPEARANCE

;; inhibit startup message
(setq inhibit-startup-message t)

;; Theme: zenburn
(use-package zenburn-theme
  :ensure t
  :config
  (load-theme 'zenburn t)
)

;; END USER CONFIG
;; THE FOLLOWIHNG IS COMPUTER GENERATED


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(zenburn-theme evil)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
