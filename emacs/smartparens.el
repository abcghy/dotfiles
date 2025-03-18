(use-package smartparens
  :config
  (add-hook 'cider-repl-mode-hook #'smartparens-mode)
  (add-hook 'clojure-mode-hook #'smartparens-strict-mode)
  (add-hook 'emacs-lisp-mode-hook #'smartparens-mode)
  (add-hook 'org-mode-hook #'smartparens-mode)
  (sp-with-modes 'org-mode
    (sp-local-pair "~" "~"))
  (sp-with-modes 'emacs-lisp-mode
    ;; https://github.com/Fuco1/smartparens/issues/1043#issuecomment-705519061
    ;; should use nil not :rem
    (sp-local-pair "'" nil :actions nil)))
