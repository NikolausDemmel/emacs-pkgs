;;; emacs-info.el --- 

(require 'info)
(add-to-list  'Info-directory-list (concat EMACS_PKGS "/info"))
(add-to-list  'Info-directory-list "/usr/share/info")

(provide 'emacs-info)

..;;; emacs-rc-info.el ends here