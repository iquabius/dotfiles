;;; config.el --- Personal Rational Emacs Config     -*- lexical-binding: t; -*-

;;; Code:
(toggle-frame-fullscreen)

(require 'rational-defaults)
(require 'rational-ui)
(require 'rational-completion)

;; Archcraft pre-installed:
;; "JetBrains Mono", "FiraCode Nerd Font", "DejaVu Sans Mono", "Source Code Pro"
(custom-set-variables '(rational-ui-default-font'(:font "FiraCode Nerd Font Light 14" :height 230)))
(set-face-attribute 'variable-pitch nil :font "Iosevka" :weight 'light)
(variable-pitch-mode 1)

(custom-set-variables '(rational-ui-display-line-numbers t))

(define-key vertico-map (kbd "C-f") 'vertico-exit)

(provide 'config)
;;; config.el ends here
