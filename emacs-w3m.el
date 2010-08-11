;;; using customize, since there appears to be no hook into the
;;; w3m-search function to activate
(add-to-list 
 'load-path (expand-file-name (concat EMACS_PKGS "/emacs-w3m")))

(if (= emacs-major-version 23)
	(require 'w3m-ems)
  (require 'w3m))


(load-library "w3m")
(load-library "w3m-search")
(autoload 'w3m-region "w3m"
  "Render region in current buffer and replace with result." t)


; column at which w3m buffer will wrap. Set to negative to set fill
; column n places from the right of the visible window
;(setq w3m-fill-column 250)
(setq w3m-fill-column -10)

;(defadvice w3m-process-filter (before w3m-remember-proxy-login activate)
;"Pass the proxy username and password to w3m"
;  (setq w3m-process-proxy-user MY_PROXY_USER)
;  (setq w3m-no-proxy-domains '("local.com" "ngc.com")))

(setq w3m-command "w3m")
(setq w3m-use-toolbar nil)

(setq w3m-command-arguments '("-no-graph"))

;; use programs contributed with the w3m distribution
(autoload 'w3m-find-file "w3m" "w3m interface function for local file." t)
(autoload 'w3m-search "w3m-search" "Search QUERY using SEARCH-ENGINE." t)

;;; causes the return key to submit a form
(setq w3m-use-form t)

; set the default save directory
(setq w3m-default-save-directory (concat HOME_DIR "/download"))

; use ange-ftp for ftp downloads
(setq w3m-use-ange-ftp t)

(setq w3m-use-cookies t)

; use tabs at the top of the w3m buffer
(setq w3m-use-tab nil)

;;; various bullet and quote characters to substitute
;(standard-display-ascii ?\225 [?+])
;(standard-display-ascii ?\221 [?\'])
;(standard-display-ascii ?\222 [?\'])
;(standard-display-ascii ?\205 [?\"])
;(standard-display-ascii ?\223 [?\"])
;(standard-display-ascii ?\224 [?\"])
;(standard-display-ascii ?\226 [?-])
;(standard-display-ascii ?\227 [?-])

;;; for a list of available engines, or to add a search engine, see
;;; the variable 'w3m-search-engine-alist' defined in w3m-search.el.
;;; It's set in the customization section at the end of this file

;(setq w3m-search-engine-alist 
;      '(("google"      "http://www.google.com/search?num=30&q=%s" nil)
;        ("courseware"  "http://www.csse.monash.edu.au/courseware/cse%s" nil)
;        ("emacs"       "http://www.emacswiki.org/cgi-bin/wiki?search=%s" nil)
;        ("freshmeat"   "http://freshmeat.net/" nil)
;        ("gdict"       "http://google.com.au/search?q=define:%s" nil)
;        ("ggroups"     "http://groups.google.com/groups?num=30&q=%s" nil)
;        ("gimages"     "http://images.google.com/images?q=%s" nil)
;        ("glinux"      "http://google.com.au/linux?q=%s" nil)
;        ("malambruno"  "http://malambruno/wiki/%s.xhtml" nil)
;        ("planetmath"  "http://planetmath.org/?op=search&term=%s" nil)
;        ("sourceforge" "http://sf.net/projects/%s" nil)
;        ("teo"         "http://www.teoma.com/search.asp?t=%s" nil)
;        ("google vidindex" "http://www.google.com/search?num=30&q=-inurl:(htm|html|php) intitle:'index of' +'last modified' +'parent directory' +description +size +(avi|mpg|wmv|mpeg) %s" nil)
;        ("wikipedia"   "http://en.wikipedia.org/wiki/Special:Search?search=%s" nil)))

;; set the default search engine
(setq w3m-search-default-engine "google")

;; From the w3m emacs wiki
;;http://www.emacswiki.org/cgi-bin/wiki/emacs-w3m#WThreeM
(defun dired-w3m-find-file ()
  "Load the current dired filename in w3m"
  (interactive)
  (require 'w3m)
  (let ((file (dired-get-filename)))
;    (if (y-or-n-p (format "Open 'w3m' %s " (file-name-nondirectory file)))
        (w3m-find-file file)))

(add-hook 'dired-mode-hook
          (lambda ()
;            (define-key dired-mode-map "3" 'dired-w3m-find-file)
            (define-key dired-mode-map "W" 'dired-w3m-find-file)
            (define-key dired-mode-map "\C-c\C-vw" 'dired-w3m-find-file)))

(defun w3m-browse-current-buffer ()
  "Browse the current html buffer in dired"
    (interactive)
    (let ((filename (concat (make-temp-file "w3m-") ".html")))
      (unwind-protect
          (progn
            (write-region (point-min) (point-max) filename)
            (w3m-find-file filename))
        (delete-file filename))))

(defun w3m-open-current-page-external ()
  "Open the current URL in an extenal browser.
The default w3m version doesn't seem to be working..."
  (interactive)
  (browse-url w3m-current-url))


(defun w3m-open-link-or-image-external ()
  "Open the current link or image in an external browser.
The default w3m version doesn't seem to be working..."
  (interactive)
  (browse-url (or (w3m-anchor)
		  (w3m-image))))

(define-key w3m-mode-map "m" 'w3m-open-current-page-external)
(define-key w3m-mode-map "M" 'w3m-open-link-or-image-external)


(provide 'emacs-w3m)
