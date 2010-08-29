;;;_* -*-mode: emacs-lisp -*-

;;;_*======================================================================
;;;_* convience functions
;;;_*======================================================================

;; for the cmBrowse function
(require 'thingatpt)

;;;_*======================================================================
;;;_* Functions to convert the line endings. Uses the eol-conversion
;;;_* package
(require 'eol-conversion)
(defun d2u ()
  "convert current buffer from dos to unix format using the
`set-buffer-eol-conversion' function withing emacs"
  (interactive)
  (if (y-or-n-p "Convert DOS to Unix format?")
      (set-buffer-eol-conversion 'unix)
    (message "format unchanged")))

(defun u2d ()
  "convert current buffer from unix to dos format using the
`set-buffer-eol-conversion' function withing emacs"
  (interactive)
  (if (y-or-n-p "Convert Unix to DOS format?")
      (set-buffer-eol-conversion 'dos)
    (message "format unchanged")))

;;;_*======================================================================
;;;_* convert a string of 3 decimal numbers to hex and place the result
;;;_* into the kill ring for pasting
(defun d2h (red green blue)
  "Convert decimal RGB color specification to hexidecimal and insert
  at the current point"
  (interactive "nRed:
nGreen:
nBlue: ")
  (let ((s (concat (format "#%02x%02x%02x" red green blue))))
           (message (concat "DEC RGB: "
                            (int-to-string red) " "
                            (int-to-string green) " "
                            (int-to-string blue) "    HEX: " s))
           ; place into the kill ring for pasting
           (kill-new s)))

;;;_*;======================================================================
;;;_*; automatically color hex color strings
;; see http://www.emacswiki.org/cgi-bin/emacs-en/HexColour for details
;(require 'cl)
;(defun hexcolour-luminance (color)
;  "Calculate the luminance of a color string (e.g. \"#ffaa00\", \"blue\").
;This is 0.3 red + 0.59 green + 0.11 blue and always between 0 and 255."
;  (let* ((values (x-color-values color))
;         (r (car values))
;         (g (cadr values))
;         (b (caddr values)))
;    (floor (+ (* .3 r) (* .59 g) (* .11 b)) 256)))
;
;(defun hexcolour-add-to-font-lock ()
;  (interactive)
;  (font-lock-add-keywords nil
;   `((,(concat "#[0-9a-fA-F]\\{3\\}[0-9a-fA-F]\\{3\\}?\\|"
;               (regexp-opt (x-defined-colors) 'words))
;      (0 (let ((colour (match-string-no-properties 0)))
;           (put-text-property
;            (match-beginning 0) (match-end 0)
;            'face `((:foreground ,(if (> 128.0 (hexcolour-luminance colour))
;                                      "white" "black"))
;                    (:background ,colour)))))))))
;
;(add-hook 'emacs-lisp-mode-hook 'hexcolour-add-to-font-lock)
;(add-hook 'nxml-mode-hook 'hexcolour-add-to-font-lock)


;;;_*======================================================================
;;;_* immediately go to the scratch buffer from anywhere else
(defun scratch ()
  "Switch to an existing *scratch* buffer or create a new one if necessary"
  (interactive)
  (switch-to-buffer "*scratch*")
  (if current-prefix-arg
      (delete-region (point-min) (point-max))
    (goto-char (point-max)))
  )

;; From: Kevin Rodgers <kevin.d.rodgers@gmail.com>
;; Subject: Re: How to get rid of *GNU Emacs* buffer on start-up?
;; Newsgroups: gnu.emacs.help
;; Date: Fri, 19 Sep 2008 20:35:08 -0600
(defun switch-to-new-buffer ()
 "Switch to a new *scratch* buffer. Creates additional buffers if
 scratch is already in use"
  (interactive)
  (switch-to-buffer (generate-new-buffer "*scratch*"))
  (setq switch-to-new-buffer t))

;;;;_*======================================================================
;;;;_* Toggle the top menu bar. Gets the max editor screen for your money!
;(defun toggle-menu-bar ()
;  "Toggle Menubar."
;  (interactive)
;  (if menu-bar-mode
;      (progn
;        (menu-bar-mode -1)
;        (set-frame-height (selected-frame) (+ (frame-height) 1)))
;    (progn
;      (menu-bar-mode 1)
;      (set-frame-height (selected-frame) (- (frame-height) 1))))
;    (force-mode-line-update t))

;;;_*======================================================================
;;;_* Generate a tabarall (tgz) from within dired
;; From: Emilio Lopes <eclig@gmx.net>
;; Subject: Re: Archiving files and directories from dired
;; Newsgroups: comp.emacs
;; tar gzip selected files and directories from within dired
(defun my-dired-do-tarball (tarfile)
  (interactive "star.tgz file name: ")
  (dired-do-shell-command (format "tar czf %s *" tarfile)
                          nil
                          (dired-get-marked-files t)))

;;;_*======================================================================
;;;_* Look up a word under the point in an online dictionary
;; From: Xah Lee <xah@xahlee.org>
;; Newsgroups: gnu.emacs.help
;; Date: Fri, 11 Apr 2008 13:25:31 -0700 (PDT)
(defun word-definition-lookup ()
"Look up the word under cursor in a browser."
 (interactive)
 (w3m-goto-url
  (concat
   "http://www.answers.com/main/ntquery?s="
   (thing-at-point 'word))))

;;;_*======================================================================
;;;_* Find a function in the elisp manual
;; From: lawrence mitchell <wence@gmx.li>
;; Find the function under the point in the elisp manual
;;
;; C-h TAB runs the command info-lookup-symbol
;;    which is an interactive autoloaded Lisp function in `info-look'.
;; [Arg list not available until function definition is loaded.]
;;
;; Display the definition of SYMBOL, as found in the relevant manual.
;; When this command is called interactively, it reads SYMBOL from the minibuffer.
;; In the minibuffer, use M-n to yank the default argument value
;; into the minibuffer so you can edit it.
;; The default symbol is the one found at point.
;;
;; With prefix arg a query for the symbol help mode is offered.
(defun find-function-in-elisp-manual (function)
  (interactive
   (let ((fn (function-called-at-point))
	 (enable-recursive-minibuffers t)
	 val)
     (setq val
	   (completing-read
	    (if fn
		(format "Find function (default %s): " fn)
	      "Find function: ")
	    obarray 'fboundp t nil nil (symbol-name fn)))
     (list (if (equal val "")
	       fn
	     val))))
  (Info-goto-node "(elisp)Index")
  (condition-case err
      (progn
	(search-forward (concat "* "function":"))
	(Info-follow-nearest-node))
    (error (message "`%s' not found" function))))


;;;_*======================================================================
;;;_* functions for setting the shell and creating shell windows.
;; Borrowed heavily from setup-cygwin.el by Markus Hoenika
;; Maintainer: Drew Adams
(defun set-shell (shellPrg)
  "Set the default shell within emacs to the shell program specified"
  (setenv "SHELL" shell-file-name)
  (setq shell-file-name          shellPrg
        explicit-shell-file-name shell-file-name
        w32-quote-process-args   t
        shell-command-switch     "-c")
  (message shell-file-name))

(defun setShell (shellPrg)
  "Interactive function to provide completion for shells to set
  the current shell within emacs. Calls `set-shell' to implement the changes"
 (interactive "i")
 (setq shellPrg
       (completing-read
        "Shell program (bash cmd cmdproxy sh tcsh zsh): "
        '(("bash" 1) ("cmd" 2) ("cmdproxy" 3) ("sh" 4) ("tcsh" 5) ("zsh" 6))
        nil t "tcsh"))
 (set-shell shellPrg))

(defun getShell ()
  "Return the name of the current shell program within emacs"
  (interactive)
  (message
   (concat "         shell-file-name: " shell-file-name "\n"
           "explicit-shell-file-name: " explicit-shell-file-name "\n"
           "    shell-command-switch: " shell-command-switch "\n"
           "  w32-quote-process-args: " (pp-to-string w32-quote-process-args))))

(defvar shell-window-height 24
  "Number of text lines to display in the shell buffer when invoked through `newShell'")

;;;_* create a new shell buffer with the selected shell program
(defun newShell(shellPrg)
  "open a shell buffer with the option of selecting a shell program to use"
  (interactive "i")
  (let ((current-shell shell-file-name))
    ; run the setShell method and get the prompt from there
    (setShell nil)
    (let ((buffer-name (concat "*" shell-file-name "*")))
      (shell buffer-name)
      (message buffer-name)
      (set-window-text-height nil shell-window-height))
    ;; return to the previous default shell
    (set-shell current-shell)))

;;;_*======================================================================
;;;_* Clear the eshell buffer
(defun eshell/clear ()
  "04Dec2001 - sailor, to clear the eshell buffer."
  (interactive)
  (let ((inhibit-read-only t))
    (erase-buffer)))


;;;_*======================================================================
;;;_* modify the buffer centering command C-l
;; (thanks to Michael.Luetzeler@unibw-muenchen.de)
(defun cm-recenter-display (arg)
  "Move point in window and redisplay screen.
First time, leaves point in the middle of the window.
Second time, leaves point near top of window.
Third time, leaves point near bottom of window.
With just one \\[universal-argument] arg, redraw screen without moving point.
With numeric arg, redraw around that line."
  (interactive "P")
    (cond ((consp arg)
	   (recenter)
	   (recenter line));; (redraw-display) bombs in Epoch 3.1.
	  (arg
	   (recenter (prefix-numeric-value arg)))
	((eq last-command 'recenter-first)
	   (setq this-command 'recenter-second)
	   (recenter 1))
	((eq last-command 'recenter-second)
	   (setq this-command nil)
	   (recenter -2))
	(t
	   (setq this-command 'recenter-first)
	   (recenter nil))))

(global-set-key "\C-l" 'cm-recenter-display)

;;;_*======================================================================
;;;_* kill trailing whitespace
;; Thanks Roman Belenov <roman@nstl.nnov.ru>
;;======================================================================
(defun kill-whitespace ()
  "Kill trailing whitespace"
  (interactive)
  (save-excursion
    (progn
      (goto-char (point-min))
      (while (re-search-forward "[ \t]+$" nil t)
	(replace-match "" nil nil)))))

;;;_*======================================================================
;;;_* Extend the behavior of query-replace
;; If a region has been marked, the query replace will only operate
;; within that region:

(defadvice query-replace (around replace-on-region activate)
  (if mark-active
      (save-excursion
	(save-restriction
	  (narrow-to-region (point) (mark))
	  (let ((mark-active nil))
	    (goto-char (point-min))
	    ad-do-it)))
    ad-do-it))

;;;_*======================================================================
;;;_* define a function to scroll with the cursor in place, moving the
;;;_* page instead
;; Navigation Functions
(defun scroll-down-in-place (n)
  (interactive "p")
  (previous-line n)
  (unless (eq (window-start) (point-min))
    (scroll-down n)))

(defun scroll-up-in-place (n)
  (interactive "p")
  (next-line n)
  (unless (eq (window-end) (point-max))
    (scroll-up n)))

(global-set-key "\M-n" 'scroll-up-in-place)
(global-set-key "\M-p" 'scroll-down-in-place)

;;;_*======================================================================
;;;_* define a function to toggle truncate lines and redraw the display
(defun trunc ()
  "Toggle the truncate-line variable"
  (interactive)
  (toggle-truncate-lines (if truncate-lines nil t)))

;;;_*======================================================================
;;;_* functions to display file and path information
;; show the full path and filename in the message area
(defun path ()
    (interactive)
    (message buffer-file-name)
    (kill-new (buffer-file-name)))

;; set filename only in the Modeline display
(defun short-file-name ()
  "Display the file path and name in the modeline"
  (interactive "*")
  (setq-default mode-line-buffer-identification '("%12b")))

;; set the full path and filename only in the Modeline display
(defun long-file-name ()
  "Display the full file path and name in the modeline"
  (interactive "*")
  (setq-default mode-line-buffer-identification
    '("%S:"(buffer-file-name "%f"))))

;;;_*======================================================================
;;;_* Define function to match a parenthesis otherwise insert a %
;;;_* requires show-paren-mode to be activated (.emacs-config)
(defun match-paren (arg)
  "Go to the matching parenthesis if on parenthesis otherwise insert %."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
	((looking-at "\\s\)") (forward-char 1) (backward-list 1))
	(t (self-insert-command (or arg 1)))))

(global-set-key "%" 'match-paren)

;;;_*======================================================================
;;;_* provide save-as functionality without renaming the current buffer
;; From: Robinows@aol.com
(defun save-as (new-filename)
  (interactive "FFilename:")
  (write-region (point-min) (point-max) new-filename))

;;;_*======================================================================
;;;_* Functions to insert the date, the time, and the date and time at
;;;_* point.
;; Useful for keeping records and automatically creating program headers
(defvar insert-time-format "%H:%M"
  "*Format for \\[insert-time]. See `format-time-string' for info on how to format.")

(defvar insert-date-format "%Y-%m-%d %a"
  "*Format for \\[insert-date]. See `format-time-string' for info on how to format.")

(defun insert-time ()
  "Insert the current time according to the variable `insert-time-format'."
  (interactive "*")
  (insert (concat (format-time-string insert-time-format (current-time)))))

(defun insert-date ()
  "Insert the current date according to the variable `insert-date-format'."
  (interactive "*")
  (insert (concat (format-time-string insert-date-format (current-time)))))

(defun insert-date-time ()
  "Insert the current date formatted with `insert-date-format',
then a space, then the current time formatted with
`insert-time-format'."
  (interactive "*")
  (progn
    (insert-date)
    (insert " ")
    (insert-time)))

(defun idt ()
  "Shortcut to `insert-date-time'"
(interactive)
(insert-date-time))

(defun insert-current-file-name ()
  (interactive)
  (insert (buffer-file-name (current-buffer))))

;;;_*======================================================================
;;;_* byte compile the current buffer on saving it
(defvar mode-specific-after-save-buffer-hooks nil
  "Alist (MAJOR-MODE . HOOK) of after-save-buffer hooks
specific to major modes.")

(defun run-mode-specific-after-save-buffer-hooks ()
  "Run hooks in `mode-specific-after-save-buffer-hooks' that match the
current buffer's major mode.  To be put in `after-save-buffer-hooks'."
  (let ((hooks mode-specific-after-save-buffer-hooks))
    (while hooks
      (let ((hook (car hooks)))
    (if (eq (car hook) major-mode)
	(funcall (cdr hook))))
      (setq hooks (cdr hooks)))))

(defun ask-to-byte-compile ()
  "Ask the user whether to byte-compile the current buffer
if its name ends in `.el' and the `.elc' file also exists."
  (let ((name (buffer-file-name)))
    (and name
     (string-match "\\.el$" name)
     (file-exists-p (concat name "c"))
     (if (y-or-n-p (format "Byte-compile %s? " name))
	 (byte-compile-file name)
       (message "")))))

(setq mode-specific-after-save-buffer-hooks
      '((emacs-lisp-mode . ask-to-byte-compile)
	(lisp-mode . ask-to-byte-compile)))

(setq after-save-hook '(run-mode-specific-after-save-buffer-hooks))

;;;_*======================================================================
;;;_* apply join-line over a region
;; From: "Ankur Jain" <jainankur@gmail.com>
;; Newsgroups: gnu.emacs.help
;; Date: Thu, 31 May 2007 10:21:00 +0530
(defun join-region (beg end)
  "Apply join-line over region."
  (interactive "r")
  (if mark-active
      (let ((beg (region-beginning))
            (end (copy-marker (region-end))))
        (goto-char beg)
        (while (< (point) end)
          (join-line 1)))))

;;;_*======================================================================
;;;_* this function prints an ascii table in a new buffer 4 columns
(defun ascii-table (&optional extended)
  "Print the ascii table (up to char 127).
Given an optional argument, print up to char 255."
  (interactive "P")
  (defvar col)
  (defvar limit)
  (setq limit 255)
  (if (null extended)
      (setq limit 127))
  (setq col (/ (+ 1 limit) 4))
  (switch-to-buffer "*ASCII*")
  (erase-buffer)
  (insert (format "ASCII characters up to %d. (00 is NULL character)\n\n" limit))
  (insert " DEC OCT HEX CHAR\t\t DEC OCT HEX CHAR\t\t DEC OCT HEX CHAR\t\t DEC OCT HEX CHAR\n")
  (insert " ----------------\t\t ----------------\t\t ----------------\t\t ----------------\n")
  (let ((i 0) (right 0) (tab-width 4))
    (while (< i col)
      (setq col2 (+ i col))
      (setq col3 (+ i (* col 2)))
      (setq col4 (+ i (* col 3)))
      (cond
	  ; insert a <TAB> instead of an actual tab
	   ((= i 9)
		(insert (format "%4d%4o%4x  <TAB>\t\t%4d%4o%4x%4c\t\t%4d%4o%4x%4c\t\t%4d%4o%4x%4c\n"
				i i i  col2 col2 col2 col2 col3 col3 col3 col3 col4 col4 col4 col4)))
           ; insert a <LF> instead of an actual line feed
	   ((= i 10)
		(insert (format "%4d%4o%4x  <LF>\t\t%4d%4o%4x%4c\t\t%4d%4o%4x%4c\t\t%4d%4o%4x%4c\n"
				i i i  col2 col2 col2 col2 col3 col3 col3 col3 col4 col4 col4 col4)))
	   (t
	    ; insert the actual character
		(insert (format "%4d%4o%4x%4c>\t\t%4d%4o%4x%4c\t\t%4d%4o%4x%4c\t\t%4d%4o%4x%4c\n"
				i i i i col2 col2 col2 col2 col3 col3 col3 col3 col4 col4 col4 col4))))
      (setq i (+ i 1))
      )
    )
  (beginning-of-buffer)
  (local-set-key "q" (quote bury-buffer)))


;;;_*======================================================================
;;;_* this command will list all available fonts. Good if the font
;;;_* you want does not appear in the font dialog
(defun list-fonts()
  "Return a list of all available fonts"
  (interactive)
    (pop-to-buffer "*fontlist*")
    (erase-buffer)
    (insert-string (prin1-to-string (x-list-fonts "*")))

    ; delete the leading ("
    (goto-char (point-min))
    (delete-char 2)

    ; replace " " with a newline
    (while (re-search-forward "\" \"" nil t)
      (replace-match "\n"))

    ; delete the trailing ")
    (goto-char (point-max))
    (delete-char -2)

    ; sort the region
    (sort-lines nil (point-min) (point-max))
    (goto-char (point-min))

    ; set the 'q' key to hide the window
    (local-set-key "q" (quote delete-window))
  )

;;;_*======================================================================
;;;_* set the current font using the font selection dialog
(defun set-font()
  "Set the default font using a font select dialog"
  (interactive)
  (ns-popup-font-panel))

;;;_*======================================================================
;;;_* get the font information for the text under the cursor
(defun what-face (point)
  "Return the font-lock face information at the current point
Thanks to Miles Bader <miles@lsi.nec.co.jp> for this (gnus.emacs.help)"
  (interactive "d")
  (let ((face (or (get-char-property (point) 'read-face-name)
		  (get-char-property (point) 'face))))
    (if face
	(message "Face: %s" face)
      (message "No face at %d" point))))

;;;_*======================================================================
;;;_* follow links from w3 or w3m region buffers (works in vm)
;; thanks to Edward O'Connor <ted@oconnor.cx>
(defun ted-follow-link-at-point (point)
  "Try to follow an HTML link at point.
This works for links created by w3-region and/or by w3m-region."
  (interactive "d")
  (let* ((props (text-properties-at point))
	 (w3-h-i (plist-get props 'w3-hyperlink-info))
	 (w3m-h-a (plist-get props 'w3m-href-anchor)))
    (cond (w3-h-i
           (browse-url (plist-get w3-h-i :href)))
	  (w3m-h-a
	   (browse-url w3m-h-a))
	  (t
	   (message "Couldn't determine link at point.")))))

;; map this function within vm to the C-j key
(add-hook 'vm-mode-hook '(lambda ()
(local-set-key "\C-j" 'ted-follow-link-at-point)))

;;;_*======================================================================
;;;_* Load various web pages into the browser of choice
(defun cmBrowse (browser &optional url &optional arg)
  "Launch the browser specified with the optional page or home page if nil"
    (if (or (string= url "") (null url))
      ; prompt for a url
      (shell-command (concat "/usr/bin/open -a " browser " "
       (if (getUrl)
           (car (browse-url-interactive-arg "URL: "))
         (read-string "URL: "))))
    
    ; use url provided
    (shell-command (concat "/usr/bin/open -a " browser " " url))))

(defun getUrl ()
  "If the point is on a string that matches
`thing-at-point-url-regexp then return the URL, else return nil"
  (if (thing-at-point-looking-at thing-at-point-url-regexp)
      (thing-at-point 'url)
    nil))

(defun browse (browser &optional url)
  "Launch the default browser with an optional URL
When called interactively, any url under the point is selected as
the default, but can be overridden by entering the desired
destination. If no URL is entered, the browser will launch with no
destination"
  (if (or (string= url "") (null url))
      ; get url from prompt (with default if possible)
      (shell-command (concat "/usr/bin/open -a " browser " --args "
       (read-string 
        (if (getUrl) 
            (format "URL (%s): " (getUrl))
          "URL: ")
        nil nil (getUrl))))
    ; load browser with provided url
    (shell-command (concat "/usr/bin/open -a " browser " --args " url))))

(defun fx (&optional url)
  "Launch the Firefox browser with an optional URL.
When called interactively, any url under the point is selected as
the default, but can be overridden by entering the desired
destination. If no URL is entered, the browser will launch with
no destination"
  (interactive)
  (cmBrowse FRFXPRG url))

(defun ch (&optional url)
  "Launch the Internet Explorer browser with an optional URL.
When called interactively, any url under the point is selected as
the default, but can be overridden by entering the desired
destination. If no URL is entered, the browser will launch with
no destination"
  (interactive)
  (cmBrowse CHRMPRG url))

(defun css ()
  "Load the Cascading Style Sheet specification into the default browser
Local or Remote (web-based) copies available"
  (interactive)
  (if (y-or-n-p "Local copy? ")
      (w3m-find-file (concat UTILS_DIR "/Reference/css/index.html"))
    (w3m-goto-url "http://www.htmlhelp.com/reference/css/index.html"))
  (message ""))

(defun html ()
  "Load the HTML 4.0 specification into w3m
Local or Remote (web-based) copies available"
  (interactive)
  (if (y-or-n-p "Local copy? ")
      (w3m-find-file (concat UTILS_DIR "/reference/html40/index.html"))
    (w3m-goto-url "http://www.htmlhelp.com/reference/html40/"))
	(message ""))

;;;_*======================================================================
;;;_* Launch various tasks (apps with predefined switches)
;; the XTerm switches and geometry are defined in the .tcshrc
(defun console ()
  "Launch a shell in the normal console location using rxvt"
  (interactive)
  (w32-shell-execute
   "open"
   "rxvt"
   (concat (getenv "CONSOLE_SWITCHES") " -T '" (getenv "HOST") "' -e tcsh")))

(defun xterm ()
  "Launch a shell using the rxvt application."
  (interactive)
  (w32-shell-execute
   "open"
   "rxvt"
   (concat (getenv "XTERM_SWITCHES") " -T 'xterm' -e tcsh")))

(defun sshfwd (&optional targetIn)
  "Launch an ssh shell to [optional] target. (panix2.panix.com is
  default) using the rxvt application, with port forwarding.
  Forwarded ports are set in the env variable SSHFWD_PORTS in the
  ~/.tcshrc as are the default fonts and colors"
	(interactive "Mtarget (panix1.panix.com): ")
	(if (string= targetIn "")
			(setq target "panix1.panix.com")
		(setq target targetIn))
	(w32-shell-execute
   "open"
   "rxvt"
   (concat (getenv "XTERM_SWITCHES") " -T '" target "' -e ssh " target " " (getenv "SSHFWD_PORTS"))))

(defun panix1 ()
	"Launch an ssh shell to panix1.panix.com with port forwarding enabled"
	(interactive)
	(sshfwd "panix1.panix.com"))
(defun panix2 ()
	"Launch an ssh shell to panix1.panix.com with port forwarding enabled"
	(interactive)
	(sshfwd "panix2.panix.com"))
(defun panix3 ()
	"Launch an ssh shell to panix3.panix.com with port forwarding enabled"
	(interactive)
	(sshfwd "panix3.panix.com"))
(defun panix5 ()
	"Launch an ssh shell to panix5.panix.com with port forwarding enabled"
	(interactive)
	(sshfwd "panix5.panix.com"))

(defun sshcmd (&optional cmdIn)
  "Launch a given command at panix2.com using the rxvt application and SSH"
  (interactive "Mcmd (tcsh): ")
   (if (string= cmdIn "")
	   (setq cmd "")
	 (setq cmd cmdIn))
  (w32-shell-execute
   "open"
   "rxvt"
   (concat (getenv "XTERM_SWITCHES") "-T 'xterm panix.com' -e ssh -lcmcmahan -tt panix5.panix.com " cmd)))

(defun cmd ()
  "Launch the NT Command console"
  (interactive)
	(w32-shell-execute
	 "open"
	 "cmd"))

(defun dterm ()
  "Launch tcsh shell with the NT shell window"
  (interactive)
  (w32-shell-execute
   "open"
   "cmd"
   "/C tcsh"))

(defun explorer ()
  "Launch the windows explorer in the current directory"
  (interactive)
  (w32-shell-execute
   "open"
   "explorer"
   (concat "/e, " (convert-standard-filename default-directory))))

;; Control panel applets
(defun control ()
  "Launch the Windows control panel"
  (interactive)
  (w32-shell-execute "open" "control.exe"))
(defun fonts ()
  "Launch the Windows font control panel applet"
  (interactive)
  (w32-shell-execute "open" "control.exe" "fonts"))
(defun display ()
  "Launch the Windows display control panel applet with the Appearance tab selected
Switches control these tab
 5 Themes
 0 Desktop
 1 Screen Saver
 2 Appearance
 3 Settings"
  (interactive)
  (w32-shell-execute "open" "control.exe" "desk.cpl, ,-2"))
(defun system ()
  "Launch the Windows system control panel applet"
  (interactive)
  (w32-shell-execute "open" "control.exe" "sysdm.cpl"))
  
;;;_*======================================================================
;;;_* Remote desktop shortcuts
(defvar rdp_directory "c:/remote_machines/"
  "Directory in which the XP Remote Desktop files are stored.
Also see the function `rd'")

; Shortcuts to get to remote machines
(defvar remote-servers
  "List of aliases and corresponding server names.")

(setq remote-servers
  '(("9nt38b1"  . "9nt38b1")
    ("b3wj6b1"  . "b3wj6b1")
    ("bdc1"     . "bdc-gaim001")
    ("bdc3"     . "bdc-gaim003")
    ("bdc4"     . "bdc-gaim004")
    ("bdc5"     . "bdc-gaim005")
    ("bdc8"     . "bdc-gaim008")
    ("bdc9"     . "bdc-gaim009")
    ("bdc10"    . "bdc-gaim010")
    ("bdc13"    . "bdc-gaim013")
    ("bdc14"    . "bdc-gaim014")
    ("dev"      . "mvl-gaimsd06")
    ("hy56d61"  . "hy56d61")
    ("intra792" . "bdc-intra792")
    ("intra799" . "bdc-intra799")
    ("intra101" . "lbn-intra101")
    ("mvl1"     . "mvl-gaimsd01")
    ("mvl3"     . "mvl-gaimsd03")
    ("mvl5"     . "mvl-gaimsd05")
    ("mvl6"     . "mvl-gaimsd06")
    ("mvl7"     . "mvl-gaimsd07")
    ("mvlcatalyst" . "mvl-catalyst001")
    ("mvlvader" . "mvl-vader")
    ("qa"       . "bdc-gaim010")
    ("m65"      . "9nt38b1")
    ("m60"      . "hy56d61")
    ("test"     . "bdc-gaim004")
    ("train"    . "mvl-gaimsd01")
    ("vader"    . "mvl-vader")))

(defun remote_desktop (target_machine &optional console_switch)
  "Launch the XP Remote Desktop app using the rdp file provided.
optional console_switch sets the remote desktop into console mode"
  (if (null console_switch)
      (w32-shell-execute "open" "c:/windows/system32/mstsc.exe" target_machine  1)
    (w32-shell-execute "open" "c:/windows/system32/mstsc.exe" (concat target_machine " /console") 1)))
  
(defun rcmd (alias)
  "Launch a cmd shell from a remote machine using the psexec command"
   (interactive
      (list
       (completing-read "Target machine: " remote-servers nil t)))
   (let ((target (or (cdr (assoc alias remote-servers))
                     (error "No such target: %s" alias))))
     (message  (concat "Opening terminal to " target))
     (w32-shell-execute "open" "cmd" (concat "/K psexec \\\\" target " cmd /K cd c:\\"))))

(defun rd (alias)
  "Launch the XP Remote Desktop app using the selected rdp file"
   (interactive
      (list
       (completing-read "Target machine: " remote-servers nil t)))
   (let ((target (or (cdr (assoc alias remote-servers))
                     (error "No such target: %s" alias))))
     (message  (concat rdp_directory (concat target ".rdp")))
     (remote_desktop (concat rdp_directory (concat target ".rdp")))))

(defun rdc (alias)
  "Launch the XP Remote Desktop app using the selected rdp file in console mode."
   (interactive
      (list
       (completing-read "Target machine: " remote-servers nil t)))
   (let ((target (or (cdr (assoc alias remote-servers))
                     (error "No such target: %s" alias))))
     (message  (concat rdp_directory (concat target ".rdp")))
     (remote_desktop (concat rdp_directory (concat target ".rdp")) 1)))

(defun rtelnet (alias)
  "Launch a cmd shell on from the remote machine"
   (interactive
      (list
       (completing-read "Target machine: " remote-servers nil t)))
   (let ((target (or (cdr (assoc alias remote-servers))
                     (error "No such target: %s" alias))))
     (message  (concat "opening " target))
     (rcmd target)))

;;;_*======================================================================
;;;_* Launch various applications
(defconst path_to_office "c:/Program Files/Microsoft Office/Office12/")

(defun access ()
  "Launch the MS Access database program"
  (interactive)
  (w32-shell-execute "open" (concat path_to_office "/msaccess.exe")))

(defun eclipse ()
  "Launch the Eclipse IDE"
  (interactive)
  ; must be in the eclipse directory to launch correctly
  (let ((eclipse-directory "c:/eclipse"))
  (w32-shell-execute
   "open"
   (concat eclipse-directory "/eclipse.exe"))))

(defun excel ()
  "Launch the MS Excel spreadsheet application"
  (interactive)
  (w32-shell-execute "open" (concat path_to_office "/excel.exe")))

(defun outlook ()
  "Launch the MS Outlook calander and email program"
  (interactive)
  (w32-shell-execute "open" (concat path_to_office "/outlook.exe") "/recycle"))

(defun powerpoint ()
  "Launch the MS PowerPoint presentation program"
  (interactive)
  (w32-shell-execute "open" (concat path_to_office "/powerpnt.exe")))

(defun project ()
  "Launch the MS Project application"
  (interactive)
  (w32-shell-execute "open" (concat path_to_office "/winproj.exe")))

(defun word ()
  "Launch the MS Word application"
  (interactive)
  (w32-shell-execute "open" (concat path_to_office "/winword.exe")))

(defun wordpad ()
  "Launch the Wordpad editor"
  (interactive)
  (w32-shell-execute
   "open"
   "C:/Program Files/Windows NT/Accessories/wordpad.exe"))

(defun hotsync ()
  "Launch the Palm hotsync program"
  (interactive)
  (w32-shell-execute "open" "c:/Program Files/palmOne/hotsync.exe"))

(defun palm ()
  "Launch the Palm desktop program"
  (interactive)
  (w32-shell-execute "open" "c:/Program Files/palmOne/palm.exe"))

(defun vern ()
  "Launch the Vern virtual desktop application"
  (interactive)
  (w32-shell-execute "open" (concat UTILS_DIR "/Vern/vern32.exe")))

(defun pskill (pid)
  "Kill the process with the specified pid"
  (interactive "sPID or Executable Name: ")
  (let ((default-directory TOP_LEVEL)))
  (shell-command (concat "pskill " pid)))

;;;_*======================================================================
;;;_* the following functions use the program nircmd
;;;_* found at http://www.nirsoft.net
(defun nircmd (cmd)
  (interactive "MCmd: " cmd)
  (w32-shell-execute "open"
                     (expand-file-name (concat UTILS_DIR "/NirCmd/nircmd.exe"))
                     cmd))

(defun cdeject ()
  "Eject the cd in drive d:"
  (interactive)
  (nircmd "cdrom open d:"))

(defun cdopen ()
  "Eject the cd in drive d:"
  (interactive)
  (cdeject))

(defun screensaver ()
  "Start the default screensaver"
  (interactive)
  (nircmd "screensaver"))

(defun lock ()
  "Lock the workstation"
  (interactive)
  (nircmd "lockws"))


;;;_*======================================================================
;;;_* Play with the volume control
(defun volset (percent &optional component)
  "Set the volume to specified percent.
Optional string 'component' refers to one of the following sound
components:
- aux
- cd
- headphones
- line
- master
- microphone
- phone
- synth
- wavein
- waveout
If a component is specified, only that component's volume is set,
otherwise, the master volume is set to the specified percentage."
  (interactive "nPercent: " percent)
  (let ((lvl (number-to-string (* 65535 (* .01 percent)))))
    (if (null component)
        (nircmd (concat "setsysvolume " lvl " master"))
    (nircmd (concat "setsysvolume " lvl " " component)))))

(defun volchange (percent &optional component)
  "Change the volume by arg percent up or down. Optional component
Optional 'component' refers to one of the possible sound components, and can be
master, waveout, synth, cd, microphone, phone, aux, line, headphones, wavein.

If a component is specified, only that component's volume is set.
The master volume is unchanged"
  (interactive "p")
  (let ((lvl (number-to-string (* 65535 (* .01 percent)))))
    (if (null component)
        (nircmd (concat "changesysvolume " lvl " master"))
    (nircmd (concat "changesysvolume " lvl " " component)))))

(defun volup (&optional component)
  "Raise the system volume 2%
Optional 'component' refers to one of the possible sound components, and can be
master, waveout, synth, cd, microphone, phone, aux, line, headphones, wavein

If a component is specified, only that component's volume is set.
The master volume is unchanged"
  (interactive)
  (if (null component)
      (volchange 2 "master")
    (volchange 2 component)))

(defun voldown (&optional component)
  "Raise the system volume 2%
Optional 'component' refers to one of the possible sound components, and can be
master, waveout, synth, cd, microphone, phone, aux, line, headphones, wavein

If a component is specified, only that component's volume is set.
The master volume is unchanged"
  (interactive)
  (if (null component)
      (volchange -2 "master")
    (volchange -2 component)))

(defun wavset (percent)
  "Set the wave output volume to the specified percent"
  (interactive "nPercent: " percent)
  (volset percent "waveout"))

(defun wavup ()
  "Raise the waveout volume"
  (interactive)
  (volup "waveout"))

(defun wavdown ()
  "Lower the waveout volume"
  (interactive)
  (voldown "waveout"))

(defun mute ()
  "UnMute the system volume"
  (interactive)
  (nircmd "mutesysvolume 1"))

(defun unmute ()
  "Mute the system volume"
  (interactive)
  (nircmd "mutesysvolume 0"))

(defun mutetoggle ()
  "Toggle the volume between mute and unmute"
  (interactive)
  (nircmd "mutesysvolume 2"))

(defun volheadphones ()
  "Reset the volume to a comfortable level for headphones"
  (interactive)
  (volset 10 "master")
  (volset 10 "waveout"))

(defun volspeakers ()
  "Reset the volume to a comfortable level for speakers"
  (interactive)
  (volset 60 "waveout")
  (volset 60 "master"))

(defun volapp()
  "Launch the windows volume application"
  (interactive)
  (w32-shell-execute "open" "C:/WINDOWS/system32/sndvol32.exe"))

(defun vol ()
  "Create a buffer to adjust the volume interactively. The
following keybindings are in effect within this buffer
  C-p or u raise volume
  M-p raise waveout volume
  C-n or d lower volume
  M-n lower waveout volume
  l launch the volume control app
  m mute/unmute
  h set the master and waveout to 10% for headphones
  s set the master and waveout to 20% for speakers
  q quit"

  ;Look at the function `read-from-minibuffer' for suggestions on how to
  ;use the minibuffer instead of a dedicated buffer for this function"
  (interactive)
  (switch-to-buffer "*volume*")
  (erase-buffer)
  (insert "Volume buffer,
- C-p raise master volume
- C-n lower master volume
- M-p raise waveout volume
- M-n lower waveout volume
- v launch the volume control app
- m toggle mute/unmute
- h set the master and waveout volume for headphones
- s set the master and waveout volume for speakers
- q quit\n\n-> ")
  (local-set-key "\C-n" (quote voldown))
  (local-set-key "\M-n" (quote wavdown))
  (local-set-key "\C-p" (quote volup))
  (local-set-key "\M-p" (quote wavup))
  (local-set-key "v"    (quote volapp))
  (local-set-key "m"    (quote mutetoggle))
  (local-set-key "h"    (quote volheadphones))
  (local-set-key "s"    (quote volspeakers))
  (local-set-key "q"    (quote bury-buffer)))

;;;_*======================================================================
;;;_* keyboard macro definitions.
;;; The macro name is just after defalias '<macro>.  You execute the
;;; macro by typing;;; Esc-x <macro_name>;;;
;;; 1) define the macro ( C-x ( to begin, type macro then C-x ) to end )
;;; 2) name the macro ( M-x name-last-kbd-macro )
;;; 3) insert the macro into your .emacs file. Go the the end of the
;;;    emacs and execute the following
;;;    M-x insert-kbd-macro <return> macro name <return>

;; bring up the color display
(defalias 'colors
  (read-kbd-macro "M-x list-colors-display RET"))

;; bring up the faces display
(defalias 'faces
  (read-kbd-macro "M-x list-faces-display RET"))

;; justification of a paragraph at the current fill column
(defalias 'justify-center
  (read-kbd-macro "M-x set-justification-center"))
(defalias 'justify-full
  (read-kbd-macro "M-x set-justification-full"))
(defalias 'justify-right
  (read-kbd-macro "M-x set-justification-right"))
(defalias 'justify-left
  (read-kbd-macro "M-x set-justification-left"))
(defalias 'justify-none
  (read-kbd-macro "M-x set-justification-none"))

;; insert text for article link in blog entry
(fset 'article
   "\C-aArticle is <a href=\"\C-e\">here</a>.")


;;;_*======================================================================
;;;_* "Unfill" a paragraph by converting to a single line
;; Stefan Monnier <foo at acm.org>. It is the opposite of
;; fill-paragraph Takes a multi-line paragraph and makes it into a
;; single line of text.
(defun unfill-paragraph ()
  (interactive)
  (let ((fill-column 46488))
    (fill-paragraph nil)))

(defun unfill-region ()   "Do the opposite of fill-region; stuff all
paragraphs in the current region into long lines."
  (interactive)
  (let ((fill-column 9000))
    (fill-region (point) (mark))))

;;;_*======================================================================
;;;_* various find commands
(defun cm-find-dired (directory filename)
  "Change shell to cmdproxy, execute the find-name-dired command
  and return to the previous shell value"
 (interactive "MDirectory: 
MFile: ")
 (let ((current-shell
  shell-file-name))
    ;; use cmdproxy to run the find program
    (set-shell "cmdproxy")
    (find-name-dired directory filename)
    ;; return to the current shell
    (set-shell current-shell)))

(defun find-backups ()
  "Find all emacs backup files (*~) from the home directory.
  Useful for deleting quickly prior to running a system backup"
  (interactive)
  (find-lisp-find-dired "~/" "~"))
;  (cm-find-dired "~/" "*~"))

(defun gnus-help ()
  "call up the list of useful gnus commands in a separate frame"
  (interactive)
  (find-file-other-frame (concat planner-directory "/EmacsGnusCommands.muse")))

;;load the page in firefox and save the file name to the clipboard
;;| filename | url |
(fset 'loadvideo
   [?\C-a tab tab ?\C-  ?\C-s ?| ?\M-b ?\M-f ?\M-w tab ?\M-x ?f ?x return return ?\C-a])

(provide 'emacs-macros)

;;;_*======================================================================
;;;_* Local variables
;;Local Variables:
;;indent-tabs-mode: nil
;;allout-layout: (-1 : 0)
;;End:
