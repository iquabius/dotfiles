;;; config.el -- Generated Crafted Emacs user configuration -*- lexical-binding: t; -*-
;; This file is generated from config.org. If you want to edit the
;; configuration, DO NOT edit config.el, edit config.org, instead.

;; Tangle the code blocks to config.el on save.
(defun org-babel-tangle-config ()
  (when (string-equal (buffer-file-name)
                      (expand-file-name "config.org" crafted-config-path))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook
          (lambda ()
            (add-hook 'after-save-hook #'org-babel-tangle-config)))

(require 'crafted-defaults)    ; Sensible default settings for Emacs
;(require 'crafted-updates)     ; Tools to upgrade Crafted Emacs
(require 'crafted-completion)  ; selection framework based on `vertico`
(require 'crafted-ui)          ; Better UI experience (modeline etc.)
;(require 'crafted-windows)     ; Window management configuration
(require 'crafted-editing)     ; Whitspace trimming, auto parens etc.
;(require 'crafted-evil)        ; An `evil-mode` configuration
(require 'crafted-org)         ; org-appear, clickable hyperlinks etc.
;(require 'crafted-project)     ; built-in alternative to projectile
;(require 'crafted-speedbar)    ; built-in file-tree
;(require 'crafted-screencast)  ; show current command and binding in modeline
;(require 'crafted-compile)     ; automatically compile some emacs lisp files

(add-hook 'emacs-startup-hook
          (lambda ()
            (custom-set-faces
             `(default ((t (:font "Input Mono Light 18" :height 130))))
             `(fixed-pitch ((t (:inherit (default)))))
             `(fixed-pitch-serif ((t (:inherit (default)))))
             `(variable-pitch ((t (:font "Liberation Sans 18")))))))

(crafted-package-install-package 'doom-themes)
;; first turn off the deeper-blue theme
(defun switch-theme-dark ()
  "Switch to dark theme."
  (progn
    (disable-theme 'doom-ayu-light)
    (load-theme 'doom-palenight t)))
(defun switch-theme-light ()
  "Switch to light theme."
  (progn
    (disable-theme 'doom-palenight)
    (load-theme 'doom-ayu-light t)))
;; Switch to light theme at sunrise
(run-at-time "07:00" nil #'switch-theme-light)
;; Switch to dark theme at sunset
(run-at-time "19:00" nil #'switch-theme-dark)

(crafted-ensure-package 'ergoemacs-mode)
(require 'ergoemacs-mode)
(ergoemacs-mode t)

(when (version<= "9.2" (org-version))
  (require 'org-tempo))

(setq org-startup-folded t)
;; Soft-wrapping
(global-visual-line-mode)
(diminish 'visual-line-mode)

(setq org-adapt-indentation t)

(crafted-ensure-package 'org-roam)
(setq-default org-roam-directory (file-truename "~/Notes"))
(require 'org-roam)
(with-eval-after-load 'org-roam
  (org-roam-db-autosync-mode))

;; To not load `custom.el' after `config.el', uncomment this line.
;; (setq crafted-load-custom-file nil)

(if (daemonp)
    (add-to-list 'default-frame-alist '(fullscreen . fullboth)))
