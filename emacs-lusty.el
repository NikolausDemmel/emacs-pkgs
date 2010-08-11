;;;_.============================================================
;;;_. Lusty-explorer dynamic filesystem explorer and buffer switcher

(add-to-list 'load-path
             (expand-file-name (concat EMACS_PKGS "/lusty")))


(when (require 'lusty-explorer nil 'noerror)

  ;; overrride the normal file-opening, buffer switching
  (global-set-key (kbd "C-x C-f") 'lusty-file-explorer)
  (global-set-key (kbd "C-x b")   'lusty-buffer-explorer)


  (add-hook 'lusty-setup-hook 'my-lusty-hook)
  (defun my-lusty-hook ()
    (define-key lusty-mode-map "\C-j" 'lusty-highlight-next))
)

(provide 'emacs-lusty)
