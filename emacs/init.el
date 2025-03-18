(setq inhibit-startup-screen t)
(setq IS-MAC (eq system-type 'darwin))
(setq IS-LINUX (eq system-type 'gnu/linux))

(setq straight-base-dir "~/.my-emacs.d/")
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'org)
(straight-use-package 'use-package)

(setq evil-undo-system 'undo-redo)

(use-package straight
  :custom
  (straight-use-package-by-default t))

(defconst user-init-dir
  (cond ((boundp 'user-emacs-directory)
	 user-emacs-directory)
	((boundp 'user-init-directory)
	 user-init-directory)
	(t "~/.emacs.d/")))

(defun load-user-file (file)
  (interactive "f")
  "Load a file in current user's configuration directory"
  (load-file (expand-file-name file user-init-dir)))


;; (use-package cider
;;   :config
;;   (add-hook 'clojure-mode-hook #'cider-mode)
;;   ;;(setq tab-always-indent 'complete)
;;   )

;; why not just load directory? Cuz for now, I want to see every plugin in the init.el file
(load-user-file "evil.el")
(load-user-file "smartparens.el")
(load-user-file "which-key.el")
(load-user-file "doom.el")
(load-user-file "dashboard.el")
(load-user-file "mini-buffer.el")
(load-user-file "consult.el")
(load-user-file "dict.el")
(load-user-file "org.el")
(load-user-file "personal.el")
(load-user-file "keybindings.el")
(load-user-file "treemacs.el")
;; (load-user-file "lsp.el")
(load-user-file "corfu.el")
