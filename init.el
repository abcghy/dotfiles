(setq inhibit-startup-screen t)

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


;; (set-frame-font "Sarasa Mono SC Nerd 18" nil t)

(set-face-attribute 'default nil :font (font-spec :family "Sarasa Mono SC Nerd" :size 18))

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
