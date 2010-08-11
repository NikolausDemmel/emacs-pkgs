;    
;     File:   /u3/ccmproc2/emacs/safeload.el  (939 bytes) 
;     Date:   Tue Dec  1 09:26:25 1992
;     Author: Lawrence Buja <ccmproc2@sunny>
;    
;; To use, put the following in your .emacs (with the appropriate
;; files and comments of course).
;;
;; (     load "safeload"         nil t )  ; error trapping load function.
;; (safeload "defaults"          nil t )  ; emacs default variable settings.
;; (safeload "hooks"             nil t )  ; various mode hooks.
;; (safeload "tools"             nil t )  ; various tools and functions.
;; (safeload "my-keys"           nil t )  ; my ESC/Control key customizations.
;; (safeload "my-print"          nil t )  ; my print buffer & region commands.
;; (safeload "compress"          nil t )  ; uncompress when loading a .Z file.
;; (safeload "all"               nil t )  ; hide/expose text.
;; (safeload "echistory"         nil t )  ; system electric history package.
;; (safeload "ispell"            nil t )  ; system electric spell package.
;; (safeload "show-file-buffers" nil t )  ; Display all buffers that are visiting files.
;; (safeload "server-start"      nil t )  ; start emacsclient server
;; (safeload "solaris-keys"      nil t )  ; Solaris specific key bindings
;; (start-server)
;; (set-mark-command nil) 

(defvar safeload-error-list ""
        "*List of files that reported errors when loaded via safeload")

(defun safeload (file &optional noerror nomessage nosuffix)
  "Load a file.  If error when loading, report back, wait for
   a key stroke then continue on"
  (interactive "f")
  (condition-case nil (load file noerror nomessage nosuffix) 
    (error 
      (progn 
       (setq safeload-error-list  (concat safeload-error-list  " " file))
       (message "****** [Return to continue] Error loading %s" safeload-error-list )
        (sleep-for 1)
       nil))))

(defun safeload-check ()
 "Check for any previous safeload loading errors.  (safeload.el)"
  (interactive)
  (if (string-equal safeload-error-list "")
      () 
    (progn
      (message (concat "****** error loading: " safeload-error-list))
      (sit-for 3))))

