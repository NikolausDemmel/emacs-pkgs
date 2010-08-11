;;;_.======================================================================
;;;_. bs (another implementation of the buffer mode (C-xC-b))
(require 'bs)

;; If you don't want to see internal buffers beginning with '*'
;; but you want to see buffer *scratch* then:
;(setq bs-dont-show-regexp "^\\*")
(setq bs-must-show-regexp "^\\*scratch\\*")

;; possible values for the configuration are:
;;    ("all"                . bs-config--all)
;;    ("files"              . bs-config--only-files)
;;    ("files-and-scratch"  . bs-config--files-and-scratch)
;;    ("all-intern-last"    . bs-config--all-intern-last)
(setq bs-default-configuration "all")

;; bind bs to the standard buffer keys (C-x\C-b)
(global-set-key "\C-x\C-b" 'bs-show)

;; fix a couple of issues with font locking
;; - Modifying dired listing switches will likely break Dired font locking
;; - Tramp ssh sessions don't get any special font locking
;; from Yone Rabkin Katzenell <yonirabkin@member.fsf.org> 
(setq bs-mode-font-lock-keywords
      (list
       ;; header in font-ock-type-face
       (list (bs--make-header-match-string)
	     '(1 font-lock-type-face append) '(1 'bold append))
       ;; buffername embedded by *
       (list "^\\(.*\\*.*\\*.*\\)$"
	     1
	     ;; problem in XEmacs with font-lock-constant-face
	     (if (facep 'font-lock-constant-face)
		 'font-lock-constant-face
	       'font-lock-comment-face))
       ;; tramp ssh inline methods
       '("^.* /ssh:..+@.+:.*$" 0 font-lock-comment-face)
       ;; Dired buffers
       '("^..\\(.*Dired .*\\)$" 1 font-lock-function-name-face)
       ;; the star for modified buffers
       '("^.\\(\\*\\) +[^\\*]" 1 font-lock-comment-face)))


(provide 'emacs-bs)
