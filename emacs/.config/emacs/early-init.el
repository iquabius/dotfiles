;;; early-init.el --- personal configuration  -*- lexical-binding: t; -*-

(load "~/.config/crafted-emacs/modules/crafted-early-init-config")

;; Pin ergoemacs to melpa
(add-to-list 'package-pinned-packages (cons 'ergoemacs-mode "melpa"))
(add-to-list 'package-pinned-packages (cons 'emacsql "melpa"))
(add-to-list 'package-pinned-packages (cons 'emacsql-sqlite "melpa"))
(add-to-list 'package-pinned-packages (cons 'org-roam "melpa"))
;; MELPA Stable's org-ref is 2.0.0 (2019) and still requires helm-config, which
;; no longer exists — it fails to load at all. Rolling MELPA has the v3 line,
;; which dropped helm.
(add-to-list 'package-pinned-packages (cons 'org-ref "melpa"))
