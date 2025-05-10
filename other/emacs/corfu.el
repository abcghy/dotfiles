(use-package corfu
  :ensure t
  :init
  ;; (global-corfu-mode)
  :hook
  ((emacs-lisp-mode . corfu-mode)
   (org-mode . corfu-mode))
  :custom
  ;; Enable auto completion
  (corfu-auto t)
  ;; Start completion after typing 2 characters
  (corfu-auto-prefix 2)
  ;; Show completion popup after 0.2 seconds
  (corfu-auto-delay 0.2)
  ;; Show 10 candidates max
  (corfu-count 10)
  ;; Always use vertical display
  (corfu-scroll-margin 5))

;; set this to nil so that org mode won't feels laggy any more if type Chinese Character
;; side effect: english spell completion no long exist for every mode
;; (setq ispell-alternate-dictionary nil)
(setq text-mode-ispell-word-completion nil)

;; Enhance Corfu with documentation popups (optional)
;; (use-package corfu-doc
;;   :ensure t
;;   :after corfu
;;   :hook (corfu-mode . corfu-doc-mode))
