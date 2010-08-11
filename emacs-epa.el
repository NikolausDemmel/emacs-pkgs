;;;_.======================================================================
;;;_. gpg mode
;; encryption using GnuPG. Visit anything.gpg and it will encrypt it
;; when you save the buffer.
(require 'epa)

;; set all encryptions as single user, no recipients specified
(setq epa-file-encrypt-to '())

;; may have the effect of forcing the all encrypted files accessed in
;; a single emacs session to have the same password
(setq epa-file-cache-passphrase-for-symmetric-encryption t)

;; If non-`nil', disable auto-saving when opening an encrypted file
(setq epa-file-inhibit-auto-save t)

(provide 'emacs-epa)
