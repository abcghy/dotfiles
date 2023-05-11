(setq inhibit-startup-screen t)
(setq IS-MAC (eq system-type 'darwin))
(setq IS-LINUX (eq system-type 'gnu/linux))

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)

(use-package straight
  :custom
  (straight-use-package-by-default t))

(use-package evil
  :config
  (evil-mode))

(use-package cider
  :config
  (add-hook 'clojure-mode-hook #'cider-mode)
  (setq tab-always-indent 'complete))

(use-package smartparens
  :config
  (add-hook 'cider-repl-mode-hook #'smartparens-mode)
  (add-hook 'clojure-mode-hook #'smartparens-strict-mode)
  (add-hook 'emacs-lisp-mode-hook #'smartparens-mode)
  (add-hook 'org-mode-hook #'smartparens-mode))

(use-package which-key
  :init
  (setq which-key-idle-delay 0.5)
  :config
  (which-key-mode))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t
	doom-themes-enable-italic t)
  (load-theme 'doom-one-light t)
  (doom-themes-visual-bell-config))

(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook))

(use-package org-bullets
  :config
  (add-hook 'org-mode-hook #'org-bullets-mode))

(add-hook 'org-mode-hook 'visual-line-mode)
(add-hook 'org-mode-hook 'org-indent-mode)

;; (set-frame-font "Sarasa Mono SC Nerd 18" nil t)

(setq font-size
      (if IS-MAC 18 36))
(set-face-attribute 'default nil :font (font-spec :family "Sarasa Mono SC Nerd" :size font-size))

(tool-bar-mode -1)

(global-display-line-numbers-mode)
(setq display-line-numbers-type 'relative)
