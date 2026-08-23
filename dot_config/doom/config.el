;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Harry Gao"
      user-mail-address "beatbox_gao@hotmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!
;; (setq doom-font (font-spec :family "Sarasa Term SC Nerd" :size 18 :weight 'semi-light))
;; |中|文|测|试|门|入|灌|
;; |It|'s| j|us|t |a |en|gl|is|h |te|st|

(setq maple-font
      (font-spec
       :family "Maple Mono NF CN"
       :size 16
       :weight 'extra-light))
(setq cascadia-font
     (font-spec
      :family "Cascadia Code NF"
      :size 16
      :weight 'light))
(setq sarasa-font
      (font-spec
       :family "Sarsasa Term SC Nerd"
       :size 16
       :weight 'light))
(setq doom-font maple-font)

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one-light)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Sync/roam/")
(setq org-roam-directory "~/Sync/roam/")
(after! org
  (setq org-emphasis-alist
        (cons '("*" (:foreground "red" :weight bold))
              (assoc-delete-all "*" org-emphasis-alist))))
(after! org
  (custom-set-faces!
    '(org-level-1 :weight normal :foreground "#1E90FF")
    '(org-level-2 :weight normal :foreground "#9370DB")
    '(org-level-3 :weight normal :foreground "#3CB371")
    '(org-level-4 :weight normal :foreground "#FF6347")
    '(org-level-5 :weight normal :foreground "#FF8C00")
    '(org-level-6 :weight normal :foreground "#20B2AA")
    '(org-level-7 :weight normal :foreground "#C71585")
    '(org-level-8 :weight normal :foreground "#9ACD32")))

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; (after! org-mode
;;   (add-hook 'org-mode-hook
;;             (lambda () (corfu-mode -1))))
;; (add-hook 'org-mode-hook (lambda () (corfu-mode -1)))

(map! :map (markdown-mode-map org-mode-map)
      :n "j" #'evil-next-visual-line
      :n "k" #'evil-previous-visual-line
      :n "0" #'evil-beginning-of-visual-line
      :n "$" #'evil-end-of-visual-line)

;; add visual-line-mode for magit status mode, because I need to use git for writing essay
;; and one paragraph is one line for git. It was hard to view the diff if visual-line-mode is off
(after! magit
  (add-hook 'magit-mode-hook #'visual-line-mode))

;; set this to nil so that org mode won't feels laggy any more if user type Chinese Character
;; side effect: english spell completion no long exist for every mode
;; may be I can set this just in org mode though
;; (setq ispell-alternate-dictionary nil)
(setq text-mode-ispell-word-completion nil)

(setq which-key-idle-delay 0.2)

(after! smartparens
  (sp-local-pair '(org-mode) "~" "~")
  (sp-local-pair '(org-mode) "_" "_"))

(add-to-list 'default-frame-alist '(undecorated . t))
