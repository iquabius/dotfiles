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

(setq doom-theme '(color-theme-solarized-light))

(defun synchronize-theme ()
  (let* ((light-theme 'doom-ayu-light)
         (dark-theme 'doom-palenight)
         (start-time-light-theme 6)
         (end-time-light-theme 18)
         (hour (string-to-number (substring (current-time-string) 11 13)))
         (next-theme (if (member hour (number-sequence start-time-light-theme end-time-light-theme))
                         light-theme dark-theme)))
    (when (not (equal doom-theme next-theme))
      (disable-theme doom-theme)
      (setq doom-theme next-theme)
      (load-theme next-theme))))

(run-with-timer 0 900 'synchronize-theme)

(crafted-ensure-package 'ergoemacs-mode)
(require 'ergoemacs-mode)
(ergoemacs-mode t)

(setq prefix-help-command #'embark-prefix-help-command)

(when (version<= "9.2" (org-version))
  (require 'org-tempo))

(setq org-startup-folded t)
;; Soft-wrapping
(global-visual-line-mode)
(diminish 'visual-line-mode)

(setq org-adapt-indentation t)

(crafted-ensure-package 'org-roam)
(setq-default org-roam-directory (file-truename "~/Notes"))
(setq org-roam-dailies-directory "Journal/")

(setq org-roam-dailies-capture-templates
      '(("d" "default" entry
         "\n* %<%H:%M> %?"
         :if-new (file+head "%<%Y/%m-%d>.org"
                            "#+title: %<%a, %b %d %Y>\n"))))

(require 'org-roam)
(with-eval-after-load 'org-roam
  (org-roam-db-autosync-mode))

(define-key org-mode-map (kbd "C-c n i") 'org-roam-node-insert)
(global-set-key (kbd "C-c n c") 'org-roam-capture)
(global-set-key (kbd "C-c n f") 'org-roam-node-find)
(global-set-key (kbd "C-c n j") 'org-roam-dailies-capture-today)

;; To not load `custom.el' after `config.el', uncomment this line.
;; (setq crafted-load-custom-file nil)

(crafted-ensure-package 'beacon)
(beacon-mode 1)
(diminish 'beacon-mode " ⓑ")

(if (daemonp)
    (add-to-list 'default-frame-alist '(fullscreen . fullboth))
  (toggle-frame-fullscreen))
