(load "~/.config/crafted-emacs/modules/crafted-early-init-config")

;; Pin ergoemacs to melpa
(add-to-list 'package-pinned-packages (cons 'ergoemacs-mode "melpa"))
(add-to-list 'package-pinned-packages (cons 'emacsql "melpa"))
(add-to-list 'package-pinned-packages (cons 'emacsql-sqlite "melpa"))
(add-to-list 'package-pinned-packages (cons 'org-roam "melpa"))
