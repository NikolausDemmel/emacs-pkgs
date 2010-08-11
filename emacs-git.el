;;;_.======================================================================
;;;_. git installation
(add-to-list 'load-path
	     (expand-file-name (concat EMACS_PKGS "/git-emacs")))
(add-to-list 'load-path
             (expand-file-name (concat EMACS_PKGS "/magit")))
(add-to-list 'load-path
             (expand-file-name (concat EMACS_PKGS "/egg")))

;;;_.======================================================================
;;;_. emacs git interface
(require 'git-emacs)

;;;_.======================================================================
;;;_. magit git interface
(require 'magit)

;;;_.======================================================================
;;;_. egg git interface, enhanced magit interface with EDIFF!!!
(require 'egg)


(provide 'emacs-git)