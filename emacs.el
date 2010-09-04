;;;_. -*-mode: emacs-lisp -*-
;; set to t for debugging
(setq debug-on-error nil)



(auto-raise-mode 1)
;;;_. =====================================================================
;;;_. .emacs --- Emacs configuration file

;; Author: Chris McMahan <cmcmahan@one.net>
;; Time-stamp: 02 Nov 2007 07:55
;; Emacsen Compatibility: Emacs22
;; OS Compatibility:      Win32 (with Cygwin utils)

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of version 2 of the GNU General Public License
;; as published by the Free Software Foundation.

;; This file is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.

;; I'm sure you already have many copies of the GPL on your machine.
;; If you're using GNU Emacs, try typing C-h C-c to bring it up. If
;; you're using XEmacs, C-h C-l does this.

;;;_. =====================================================================
;;;_. set the location of various directories

(defconst HOME_DIR (concat "/Users/" (getenv "USER"))
  "Home directory. I could rely on the HOME environment variable,
  but I'm being retentive. Default uses `CYGWIN_DIR' as a
  prefix")

(defconst EMACS_PKGS (concat HOME_DIR "/emacs-pkgs")
  "Directory for the emacs pkgs and configuration files.
 Default uses `HOME_DIR' as a prefix")

(defconst MY_TRYOUT_DIR (concat HOME_DIR "/Downloads/tryout")
  "Directory for extracting files")


;;;_. =====================================================================
;;;_. select your preferred programs for html and media here
(defconst MPPRG "/Applications/VLC.app/"
  "Media Player program, video and streaming audio")
(defconst FRFXPRG "/Applications/Firefox.app/" ;Contents/MacOS/firefox"
  "points to the Mozilla Firefox location")
(defconst CHRMPRG "/Applications/Google\\ Chrome.app"
  "points to the Mozilla Firefox location")
(defconst BRWSR FRFXPRG
  "set the default browser to use within emacs")

; set the location of firefox for the browse-url-package
(setq browse-url-firefox-program FRFXPRG)


;; =====================================================================
;; various startup settings

;; Set the command key to act as the meta key
(setq mac-command-modifier 'meta)

;; isolate customize settings
(setq custom-file (concat EMACS_PKGS "/emacs-custom.el"))

(defvar my_email_address "cmcmahan@gmail.com"
  "email address to use in emacs configuration")

;; turn off the scrollbar
(set-scroll-bar-mode nil)

;; allow narrow-to-region commands
(put 'narrow-to-region 'disabled nil)

;; frame size and locations
(setq default-frame-alist
      '((top . 35) (left . 250)
        (width . 230) (height . 85)
        (cursor-color . "yellow")
        (cursor-type . box)
        (font . "Menlo 12")))

(setq initial-frame-alist default-frame-alist)

;;Syntax highlighting, can we say yes please?
(global-font-lock-mode t)

;Lets us see col # at the bottom. very handy.
(column-number-mode 1)

;buffer-name completion for C-x b; makes life much easier.
(iswitchb-mode 1)

;;;; Removes gui elements ;;;;
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))  ; no gui scrollbare
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))      ; no toolbar!
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))      ; no menubar


;;;_. =====================================================================
;;;_. load path for various single-file packages
(setq load-path 
      (append 
       (list (concat EMACS_PKGS "")
             (concat EMACS_PKGS "/misc"))
       load-path))

;; Specify where backup files are stored
(setq backup-directory-alist (quote ((".*" . "~/.backups"))))

;;;_. =====================================================================
;;;_. load the customize configurations files
(require 'emacs-bm)        ; bookmark enhancements
(require 'emacs-calendar)  ; calendar settings
(require 'emacs-bbdb)      ; big-brother database
(require 'emacs-bs)        ; buffer switch setting
(require 'emacs-colors)    ; color theme settings
(require 'emacs-todochiku) ; notification using growl
(require 'emacs-org)       ; emacs org mode settings
(require 'emacs-dired)     ; dired settings
(require 'emacs-git)       ; emacs gpg encryption settings
(require 'emacs-epa)       ; emacs gpg encryption settings
(require 'emacs-macros)    ; various macros and functions
(require 'emacs-misc)      ; various settings
(require 'emacs-webjump)   ; webjump settings
(require 'emacs-w3m)       ; w3m web browser settings


;;; =====================================================================
;; tell OS-X to raise the emacs frame on launching
;; Or else you can use the OS-X 'open' command when launching emacs. 
;; When doing this, reference the emacs.app, not the executable itself
;; Sample .tcshrc alias entry is:
;; alias emacs 'open /Applications/Emacs.app'
;(defun ns-raise-emacs ()
;  (ns-do-applescript "tell application \"Emacs\" to activate"))
;
;(ns-raise-emacs)



;; =====================================================================
;; start the emacsserver that listens to emacsclient
(server-start)

;; =====================================================================
;; some reference stuff
;; Flash a message in the echo area. This works well for debugging an
;; .emacs file by placing various messages throughout
;(message "Hello, this is .emacs speaking")
;(sit-for 3) ; 3 seconds

;;;_. ======================================================================
;;;_. Local variables

;;Local Variables:
;;indent-tabs-mode: nil
;;allout-layout: (-1 : 0)
;;End:

(provide 'emacs)