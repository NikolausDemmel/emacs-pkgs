;;;_.======================================================================
;;;_. emacs bookmark enhancements
(add-to-list 'load-path
	     (expand-file-name (concat EMACS_PKGS "/bm")))

(autoload 'bm-toggle   "bm" "Toggle bookmark in current buffer." t)
(autoload 'bm-next     "bm" "Goto bookmark."                     t)
(autoload 'bm-previous "bm" "Goto previous bookmark."            t)

(provide 'emacs-bm)