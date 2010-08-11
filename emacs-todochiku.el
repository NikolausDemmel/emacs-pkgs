;;;_.============================================================
;;;_. ToDoChiku Growl Notification Integration
(add-to-list 'load-path
             (expand-file-name (concat EMACS_PKGS "/todochiku")))

;;;_.============================================================
;;;_. load todochiku
(require 'todochiku)


;; use neat and nifty icons in the growl notification windows
(setq todochiku-icons-directory (concat EMACS_PKGS "/todochiku/todochiku-icons"))

;; Tell org-mode to use todochiku for notification
(setq org-show-notification-handler
      '(lambda (notification)
         (todochiku-message "org-mode notification" notification
                            (todochiku-icon 'emacs))))

(provide 'emacs-todochiku)