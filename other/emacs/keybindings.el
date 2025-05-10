(evil-set-leader 'normal (kbd "<SPC>"))

(evil-define-key 'normal 'global
  (kbd "<leader>ff") 'find-file
  (kbd "<leader>fr") 'consult-recent-file
  (kbd "<leader>wj") 'evil-window-down
  (kbd "<leader>wk") 'evil-window-up
  (kbd "<leader>wh") 'evil-window-left
  (kbd "<leader>wl") 'evil-window-right
  (kbd "<leader>wc") 'evil-window-delete
  (kbd "<leader>bn") 'next-buffer
  (kbd "<leader>bp") 'previous-buffer
  (kbd "<leader>bb") 'consult-buffer
  (kbd "<leader>oc") 'org-capture
  (kbd "<leader>ogn") 'org-go-to-note
  (kbd "<leader>hf") 'describe-function
  (kbd "<leader>hv") 'describe-variable)
