(setq inhibit-startup-screen t)
(setq IS-MAC (eq system-type 'darwin))
(setq IS-LINUX (eq system-type 'gnu/linux))

;; Set up package.el to work with MELPA
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; only the first time or later if you want to update plugin, you need to refresh contents
;;(package-refresh-contents)

(defun ensure-install (package-name)
  (unless (package-installed-p package-name)
    (package-install package-name)))

;; Download Evil
;; (unless (package-installed-p 'evil)
;;   (package-install 'evil))
(ensure-install 'evil)

;; Enable Evil
(require 'evil)
(evil-mode 1)

(ensure-install 'cider)
(add-hook 'clojure-mode-hook #'cider-mode)
;; enable cider tab code completion
(setq tab-always-indent 'complete)

(ensure-install 'smartparens)

(require 'smartparens-config)
(add-hook 'cider-repl-mode-hook #'smartparens-mode)
(add-hook 'clojure-mode-hook #'smartparens-strict-mode)
(add-hook 'emacs-lisp-mode-hook #'smartparens-mode)

(ensure-install 'which-key)
(require 'which-key)
(setq which-key-idle-delay 500)
(which-key-mode)

;; (set-frame-font "Sarasa Mono SC Nerd 18" nil t)

(setq font-size
      (if IS-MAC 18 36))
(set-face-attribute 'default nil :font (font-spec :family "Sarasa Mono SC Nerd" :size font-size))

(tool-bar-mode -1)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(evil)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
