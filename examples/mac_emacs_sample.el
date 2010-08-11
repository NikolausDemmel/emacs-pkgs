;;; .emacs - an emacs initialization file created by Bill Clementson

;;__________________________________________________________________________
;;;;    Site-Specific Variables 

;; Some file locations are relative to the HOME or the BIN directory
(defvar home-dir)
(setq home-dir (concat (expand-file-name "~") "/"))
(defvar bin-dir (concat home-dir "bin/"))

(defvar common-lisp-hyperspec-root (concat bin-dir "docs/Hyperspec/"))

;; Set up load path 
(setq load-path (append (list (concat home-dir "")
			      (concat bin-dir "site-lisp/slime")
			      (concat bin-dir "site-lisp/tiny-tools/lisp/tiny")
			      (concat bin-dir "site-lisp"))
                        load-path))

;; Specify where backup files are stored
(setq backup-directory-alist (quote ((".*" . "~/.backups"))))

;; Location of Info documentation
(setenv "INFOPATH" nil t)
(setq-default Info-default-directory-list
	      (list (concat bin-dir "info")
		    "/Applications/AquaMacs/Emacs.app/Contents/Resources/info"))

;;__________________________________________________________________________
;;;;    Initial Code Load

(require 'dired)
(require 'slime)
(require 'blogmax)
(load (concat bin-dir "site-lisp/" "blogmax-mods.el"))
(require 'color-theme)
(load (concat bin-dir "site-lisp/" "color-theme-mods.el"))

;;__________________________________________________________________________
;;;;    System Customizations 

;; Misc customizations
(defconst use-backup-dir t)   
(defconst query-replace-highlight t) 
(defconst search-highlight t)        

;; Always re-indent the top-level sexp
(defadvice indent-sexp (around indent-defun (&optional endpos))
  "Indent the enclosing defun (or top-level sexp)."
  (interactive)
  (save-excursion
    (beginning-of-defun)
    ad-do-it))

(ad-activate 'indent-sexp)

(defun max-frame ()
  "Maximize frame for my 17 inch PowerBook."
  (interactive)
  (set-frame-position (selected-frame) 0 0)
  (set-frame-size (selected-frame) 199 51))

;; Dired customizations
(setq ls-lisp-dirs-first t)          
(setq dired-listing-switches "-l")

(defun dired-mouse-find-file (event)
  "In dired, visit the file or directory name you double-click on (EVENT)."
  (interactive "e")
  (let (file)
    (save-excursion
      (set-buffer (window-buffer (posn-window (event-end event))))
      (save-excursion
	(goto-char (posn-point (event-end event)))
	(setq file (dired-get-filename))))
    (select-window (posn-window (event-end event)))
    (find-file (file-name-sans-versions file t))))

(defun my-dired-find-file ()
  "In dired, visit the file or directory name you are on (in the same window)."
  (interactive)
  (let (file)
    (save-excursion
      (setq file (dired-get-filename))
      (find-file (file-name-sans-versions file t)))))

(add-hook 'dired-mode-hook
	  '(lambda()
	     (define-key dired-mode-map [delete] 'dired-do-delete)
	     (define-key dired-mode-map [C-return] 'dired-find-file-other-window)
	     (define-key dired-mode-map [C-down-mouse-1] 'mouse-buffer-menu)
	     (define-key dired-mode-map [double-down-mouse-1] 'dired-mouse-find-file)	     
	     (define-key dired-mode-map [return] 'my-dired-find-file)))

;; Mac Open/Execute from dired
(define-key dired-mode-map "w"
  (function
   (lambda ()
     (interactive)
     (shell-command (concat "/usr/bin/open " (dired-get-filename))))))

;; Word completion customizations
(defconst dabbrev-always-check-other-buffers t)
(defconst dabbrev-abbrev-char-regexp "\\sw\\|\\s_")

(setq hippie-expand-try-functions-list
      '(try-expand-dabbrev
	try-expand-dabbrev-all-buffers
	try-expand-dabbrev-from-kill
	try-complete-file-name-partially
	try-complete-file-name
	try-complete-lisp-symbol-partially
	try-complete-lisp-symbol
	try-expand-whole-kill))

(global-set-key [(meta /)] 'hippie-expand)

;;__________________________________________________________________________
;;;;    Programming - Common Lisp

;; Specify modes for Lisp file extensions
(setq auto-mode-alist
      (append '(
		("\\.lisp$" . lisp-mode)
		("\\.lsp$" . lisp-mode)
		("\\.cl$" . lisp-mode)
		("\\.asd$" . lisp-mode)
		("\\.system$" . lisp-mode)
		)auto-mode-alist))

(defun insert-balanced-comments (arg)
  "Insert a set of balanced comments around the s-expression 
   containing the point.  If this command is invoked repeatedly
   (without any other command occurring between invocations), the 
   comment progressively moves outward over enclosing expressions."
  (interactive "*p")
  (save-excursion
    (when (eq last-command this-command)
      (when (search-backward "#|" nil t)
        (save-excursion
          (delete-char 2)
          (while (and (< (point) (point-max)) (not (looking-at " *|#")))
            (forward-sexp))
          (replace-match ""))))
    (while (> arg 0)
      (backward-char 1)
      (cond ((looking-at ")") (incf arg))
            ((looking-at "(") (decf arg))))
    (insert "#|")
    (forward-sexp)
    (insert "|#")))

(defun remove-balanced-comments ()
  "Remove a set of balanced comments enclosing point."
  (interactive "*")
  (save-excursion
    (when (search-backward "#|" nil t)
      (delete-char 2)
      (while (and (< (point) (point-max)) (not (looking-at " *|#")))
	(forward-sexp))
      (replace-match ""))))

(defun clhs-info ()
  (interactive)
  (ignore-errors
    (info (concatenate 'string "(gcl) " (thing-at-point 'symbol)))))

(global-set-key [(control c) (l)] 'slime-selector)

(add-hook 'lisp-mode-hook (lambda ()
			    (slime-mode t)
			    (define-key lisp-mode-map [(control j)] 'newline)
			    (define-key lisp-mode-map [(control m)] 'newline-and-indent)
			    (define-key lisp-mode-map [(control c) (\;)] 'insert-balanced-comments)
			    (define-key lisp-mode-map [(control c) (:)] 'remove-balanced-comments)
			    (define-key lisp-mode-map [f1] 'clhs-info)
			    (require 'hyperspe-addon)
			    (set (make-local-variable lisp-indent-function)
				 'common-lisp-indent-function)))

(add-hook 'inferior-lisp-mode-hook (lambda ()
				     (inferior-slime-mode t)
				     (define-key inferior-lisp-mode-map [f1] 'clhs-info)))

(slime-autodoc-mode)

;; Franz Allegro Common Lisp
(defun acl ()
  (interactive)
  (setq inferior-lisp-program (concat bin-dir "acl-7.0/alisp"
				      " -L " home-dir ".slime.lisp"))
  (load "slime"))

;; GNU CLISP
(defun clisp ()
  (interactive)
  (setq clisp-dir (concat bin-dir "clisp-2.33/base/"))
  (setq inferior-lisp-program (concat clisp-dir "lisp.run"
				      " -M " clisp-dir "lispinit.mem"
				      " -i " home-dir ".slime.lisp"
				      " -ansi -q"))
  (load "slime"))

;; CMUCL
(defun cmucl ()
  (interactive)
  (setq cmucl-dir (concat bin-dir "cmucl/bin"))
  (setenv "PATH" (concat cmucl-dir ":" (getenv "PATH")))
  (setq inferior-lisp-program (concat cmucl-dir "/lisp"))
  (load "slime"))

;; OpenMCL
(defun openmcl ()
  (interactive)
  (setq openmcl-dir (concat bin-dir "ccl"))
  (setenv "PATH" (concat openmcl-dir ":" (getenv "PATH")))
  (setenv "CCL_DEFAULT_DIRECTORY" openmcl-dir)
  (setq inferior-lisp-program (concat openmcl-dir "/dppccl"))
  (load "slime"))

;; SBCL
(defun sbcl ()
  (interactive)
  (setq sbcl-dir (concat bin-dir "sbcl/bin"))
  (setenv "PATH" (concat sbcl-dir ":" (getenv "PATH")))
  (setenv "SBCL_HOME" (concat bin-dir "sbcl/lib/sbcl"))
  (setq inferior-lisp-program (concat sbcl-dir "/sbcl"))
  (load "slime"))

;; Xanalys LispWorks
(defun lw ()
  (interactive)
  (shell-command "~/Library/Scripts/lw-start.app&")
  (delete-other-windows)
  (defun slime ()
    "Start Slime without an inferior lisp."
    (interactive)
    (while (not (ignore-errors (slime-connect "localhost" 4005) t))
      (sit-for 1))))
 
;; Specify the default CL implementation:
(openmcl)

;; Shortcut key for starting Slime
(global-set-key [f5] 'slime)

;;__________________________________________________________________________
;;;;    Programming - Elisp

(add-hook 'emacs-lisp-mode-hook
	  '(lambda ()
	     (interactive)
	     (require 'eldoc)
	     (turn-on-eldoc-mode)
	     (setq tinylisp-:mode-prefix-key  "$")
	     (require 'tinylisp)
	     ;; Default to auto-indent on Enter
	     (define-key emacs-lisp-mode-map [(control j)] 'newline)
	     (define-key emacs-lisp-mode-map [(control m)] 'newline-and-indent)))

;;__________________________________________________________________________
;;;;    Standard Key Overrides

;; Prevent accidentally killing emacs.
(global-set-key [(control x) (control c)]
		'(lambda ()
		   (interactive)
		   (if (y-or-n-p-with-timeout "Do you really want to exit Emacs ? " 4 nil)
		       (save-buffers-kill-emacs))))

;; Control iTunes from Emacs
(setq itunes-key [f3]) 
(require 'osx-itunes)  

;; Common buffer/window control shortcuts
(global-set-key [f4] 'kill-this-buffer)
(global-set-key [f6] 'other-window)
(global-set-key [f7] 'delete-other-windows)
(global-set-key [f8] 'speedbar-frame-mode)

;; bash
(global-set-key [ f12] 
		'(lambda ()
		   (interactive)
		   (let ((explicit-shell-file-name "bash")
			 (shell-file-name "bash"))
		     (shell))))

;; Shortcuts to common functions
(global-set-key [(control c) (f)] 'find-function-at-point)
(global-set-key [(control c) (F)] 'ffap)
(global-set-key [(control c) (j)] 'join-line)
(global-set-key [(control c) (m)] 'max-frame)

;;__________________________________________________________________________
;;;;    Customizations

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
  '(cua-mode t nil (cua-base))
 '(fringe-mode (quote (nil . 0)) nil (fringe))
  '(one-buffer-one-frame nil nil (drews_init))
  '(tool-bar-mode nil nil (tool-bar)))

;; end of .emacs
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )