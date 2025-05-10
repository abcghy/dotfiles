(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  ;; (setq evil-want-C-i-jump nil)
  :config
  (evil-mode))

;; in order to keep <tab>'s original function in normal mode
;; (evil-define-key 'normal org-mode-map (kbd "<tab>") #'org-cycle)

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))
