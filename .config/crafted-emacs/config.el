;;; config.el --- Personal Crafted Emacs Config     -*- lexical-binding: t; -*-

;;; Code:
(toggle-frame-fullscreen)

(crafted-ensure-package 'ergoemacs-mode)
(require 'ergoemacs-mode)
(ergoemacs-mode t)

(require 'crafted-defaults)
(require 'crafted-ui)
(require 'crafted-completion)

;; Archcraft pre-installed:
;; "JetBrains Mono", "FiraCode Nerd Font", "DejaVu Sans Mono", "Source Code Pro"
(custom-set-variables '(crafted-ui-default-font'(:font "Input Mono Normal 12" :height 130)))
;;(set-face-attribute 'variable-pitch nil :font "Iosevka" :weight 'light)
;; (eval-after-load "projectile")??
(variable-pitch-mode 1)

(custom-set-variables '(crafted-ui-display-line-numbers t))

(define-key vertico-map (kbd "C-f") 'vertico-exit)

(when (version<= "9.2" (org-version))
  (require 'org-tempo))

(setq org-startup-folded t)
;; Didn`t work
;; (setq org-startup-truncated nil)
;; Try
(toggle-truncate-lines)

(provide 'config)
;;; config.el ends here
