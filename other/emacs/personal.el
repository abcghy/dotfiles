;; (ensure-install 'nano-theme)
;; (load-theme 'nano-light)

;; (set-frame-font "Sarasa Mono SC Nerd 18" nil t)

(setq font-size
      (if IS-MAC 18 18))
(setq font-name
      (if IS-MAC "Sarasa Term SC Nerd" "Sarasa Term SC Nerd"))
(set-face-attribute 'default nil :font (font-spec :family font-name :size font-size))

(tool-bar-mode -1) ;; disable mac menu bar
(menu-bar-mode -1) ;; disable linux menu bar

(global-display-line-numbers-mode)
(setq display-line-numbers-type 'relative)

;; I prefer command as meta
(setq mac-command-modifier 'meta
      mac-option-modifier 'super)
