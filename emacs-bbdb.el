;;; -*-mode: emacs-lisp -*-

;;; Time-stamp: <2007-04-02 10:33:51 ak9384>

;;;======================================================================
;;; bbdb
;;;======================================================================
;;  is an emacs-based contact database that hooks well in the mail
;;  and gnus programs. It can also be used to conviently look up
;;  names, addresses, and phone numbers from within emacs itself by
;;  typing M-x bbdb <RET>
(add-to-list 'load-path
              (expand-file-name (concat EMACS_PKGS "/bbdb/lisp")))

(require 'bbdb-autoloads)
(require 'bbdb)


;;;======================================================================
;;; bbdb vm settings
;(bbdb-initialize 'vm 'message)
;
;;; prevent bbdb from generating a popup buffer on vm. Good for small screens
;(setq bbdb-use-pop-up nil)
;

(setq bbdb-default-area-code 513
      bbdb-file (expand-file-name (concat HOME_DIR "/.bbdb"))
      bbdb-north-american-phone-numbers-p t
      bbdb-dwim-net-address-allow-redundancy t)

;;;======================================================================
;;; use the name or the first email address on completion
(setq bbdb-completion-type (quote primary-or-name))

;;;======================================================================
;;; Whether bbdb-complete-name (M-x bbdb-complete-name in mail-mode)
;;; will update the *BBDB* buffer to display the record whose email
;;; address has just been inserted.
(setq bbdb-completion-display-record nil)

;;; set the from address
(setq bbdb-user-mail-names my_email_address)

;;;======================================================================
;;; adds or updates a timestamp notes field for each record to flag when
;;; it was created (set by default) or changed (set by default)
;(setq bbdb-create-hook bbdb-creation-date-hook)
;(add-hook 'bbdb-change-hook 'bbdb-timestamp-hook)
(setq bbdb-create-hook nil)
(setq bbdb-change-hook nil)

;; if non-nil automatically generate database records for every mail
;; message viewed
(setq bbdb/mail-auto-create-p nil)

;; if non-nil, pop a database record of every mail sender when
;; message is viewed. If a record for a mail message does not exist,
;; use : to create a new one. display vbls control the popup format
(setq bbdb-use-pop-up t)

;; format the popup display
;; necessary to get the pop-up-target-lines less than 3
(setq window-min-height 1)
(setq bbdb-pop-up-target-lines 2)

;;; turn on the electric mode (t) for popup behavior
(setq bbdb-electric-p t)

;;; format the default bbdb display and popup display
;;; Need to find out how to tweak or create a 1 line display that I
;;; can customize further to show useful information in the phone
;;; field.
(setq bbdb-display-layout-alist 
            '((one-line (order phones net)
                        (name-end . 24) (toggle . t))
              (multi-line (omit timestamp)
                          (order net phones addresses mail-alias notes t)
                          (toggle . t))
              (pop-up-multi-line 
               (omit addresses phones timestamp aka)
               (toggle . nil))
              (full-multi-line (toggle . nil))))

      (setq bbdb-display-layout 'multi-line)
      (setq bbdb-pop-up-display-layout 'pop-up-multi-line)

;;; automatically uppercase the state names in bbdb
(add-hook 'bbdb-change-hook 'wsm-bbdb-upcase-states)
(defun wsm-bbdb-upcase-states (r)
  (mapcar
   '(lambda (addr)
      (bbdb-address-set-state addr (upcase (bbdb-address-state addr))))
   (bbdb-record-addresses r)))

;;;======================================================================
;;; bbdb-query is an add-on package that provides the following commands within a
;;; BBDB buffer to refine a query on the results of the previous query:
;;; "B" query
;;; "A" append
;;; "F" flush
;;; "K" keep
;(require 'bbdb-query)

;;;======================================================================
;;; Add tags to bbdb records
;; from Sacha Chua
;; http://www.emacswiki.org/cgi-bin/wiki/BbdbTags
;;Tagging records
;;Tagging one record is as simple as addind a new user field to it.
;;
;;On the record, typo C-o and on the prompt, type "tags" as the field name.
;;Then just add your tag words separated by a blank.
;;Searching
;;
;;To list all records matching a certain tag, just do :
;; M-x sacha/bbdb-search-tags RET
;;Then enter one or more tags to match.

(defun sacha/bbdb-get-tags (record)
  "Return the tags for RECORD as a list."
  (let ((tags (bbdb-record-getprop record 'tags)))
    (when tags (split-string tags))))

(defun sacha/bbdb-test-tags (query tags)
 "Return non-nil if QUERY is a subset of TAGS."
 (let ((result t))
   (while (and result query)
     (unless (member (car query) tags)
       (setq result nil))
     (setq query (cdr query)))
   result))

(defun sacha/bbdb-search-tags-internal (records tags)
 "Return a list of RECORDS matching TAGS."
 (when (stringp tags) (setq tags (split-string tags)))
 (let (result)
   (while records
     (when (sacha/bbdb-test-tags tags
                                 (sacha/bbdb-get-tags (car records)))
       (setq result (cons (car records) result)))
     (setq records (cdr records)))
   result))

(defun sacha/bbdb-search-tags (tags)
 "Display all the records that match TAGS."
 (interactive "MTags: ")
 (bbdb-display-records (sacha/bbdb-search-tags-internal (bbdb-records) tags)))

(defun sacha/planner-bbdb-link (record)
 "Return a link to RECORD."
 (or (bbdb-record-getprop record 'plan)
     ;; From a BBDB entry with a plan page; use that. Yay!
     (concat "[["
             (emacs-wiki-replace-regexp-in-string
              " " "."
              (bbdb-record-name record))
             "][" (bbdb-record-name record)
             "]]")))

(defun sacha/bbdb-get-tags-index ()
 "Return a list of tags and records."
 (let ((tags-alist '())
       (records (bbdb-records))
       tags
       entry
       list
       link)
   (while records
     (setq tags (sacha/bbdb-get-tags (car records)))
     (while tags
       (setq entry (assoc (car tags) tags-alist))
       (setq list (cdr entry))
       (add-to-list 'list (car records))
       (if entry
           (setcdr entry list)
         (add-to-list 'tags-alist (cons (car tags) list)))
       (setq tags (cdr tags)))
     (setq records (cdr records)))
   tags-alist))

(provide 'emacs-bbdb)