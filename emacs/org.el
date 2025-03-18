(use-package org-bullets
  :config
  (add-hook 'org-mode-hook #'org-bullets-mode))

(add-hook 'org-mode-hook 'visual-line-mode)
(add-hook 'org-mode-hook 'org-indent-mode)
(setq org-directory "~/Sync/org")
(setq org-roam-directory "~/Sync/roam")
(setq note-file (concat org-directory "/notes.org"))
(setq org-default-notes-file note-file)
(setq org-refile-use-outline-path 'file)
(setq org-return-follows-link t)

(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory (file-truename org-roam-directory))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ;; Dailies
         ("C-c n j" . org-roam-dailies-capture-today))
  :config
  ;; If you're using a vertical completion framework, you might want a more informative completion interface
  ;; (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-db-autosync-mode)
  ;; If using org-roam-protocol
  (require 'org-roam-protocol))

(defun org-go-to-note()
  (interactive)
  (find-file note-file))

;; add red foreground for bold text
(add-to-list 'org-emphasis-alist '("*" (:foreground "red")))

;; set it to nil so that when M-RET, it won't break the current line
(setq org-M-RET-may-split-line nil)
